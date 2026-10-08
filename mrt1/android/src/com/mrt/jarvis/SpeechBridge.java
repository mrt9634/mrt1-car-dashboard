package com.mrt.jarvis;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.content.pm.PackageManager;
import android.Manifest;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.util.Log;

import java.util.ArrayList;
import java.util.Locale;
import java.nio.charset.StandardCharsets;
import java.security.KeyStore;
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import android.util.Base64;

public final class SpeechBridge {
    private static final String TAG = "SpeechBridge";

    private static SpeechRecognizer recognizer;
    private static TextToSpeech tts;
    private static boolean ttsReady = false;
    private static String pendingSpeakText = null;
    private static String pendingSpeakLocale = null;

    private static final String KEYSTORE = "AndroidKeyStore";
    private static final String KEY_ALIAS = "MRT1_OpenAI_Key";
    private static final String PREFS = "mrt1_secure";
    private static final String KEY_NAME = "openai_key";

    private SpeechBridge() {}

    private static Context qtContext() {
        android.app.Activity activity = org.qtproject.qt.android.QtNative.activity();
        return activity != null ? activity : null;
    }

    // ─── Secure API key storage ────────────────────────────────
    private static SecretKey getOrCreateKey() throws Exception {
        KeyStore ks = KeyStore.getInstance(KEYSTORE);
        ks.load(null);

        if (ks.containsAlias(KEY_ALIAS)) {
            KeyStore.Entry entry = ks.getEntry(KEY_ALIAS, null);
            if (entry instanceof KeyStore.SecretKeyEntry) {
                return ((KeyStore.SecretKeyEntry) entry).getSecretKey();
            }
        }

        KeyGenerator kg = KeyGenerator.getInstance("AES", KEYSTORE);
        kg.init(new android.security.keystore.KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                android.security.keystore.KeyProperties.PURPOSE_ENCRYPT |
                android.security.keystore.KeyProperties.PURPOSE_DECRYPT)
            .setBlockModes(android.security.keystore.KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(android.security.keystore.KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .setRandomizedEncryptionRequired(true)
            .build());
        return kg.generateKey();
    }

    public static String loadApiKey() {
        try {
            Context context = qtContext();
            if (context == null) return "";

            String packed = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .getString(KEY_NAME, "");
            if (packed == null || packed.isEmpty()) return "";

            byte[] all = Base64.decode(packed, Base64.DEFAULT);
            if (all.length < 13) return "";

            byte[] iv = new byte[12];
            System.arraycopy(all, 0, iv, 0, 12);
            byte[] cipherText = new byte[all.length - 12];
            System.arraycopy(all, 12, cipherText, 0, cipherText.length);

            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.DECRYPT_MODE, getOrCreateKey(),
                        new GCMParameterSpec(128, iv));
            return new String(cipher.doFinal(cipherText), StandardCharsets.UTF_8);
        } catch (Exception e) {
            Log.e(TAG, "loadApiKey failed: " + e.getMessage());
            return "";
        }
    }

    public static boolean saveApiKey(String value) {
        try {
            Context context = qtContext();
            if (context == null) return false;
            if (value == null || value.trim().isEmpty()) return false;

            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.ENCRYPT_MODE, getOrCreateKey());
            byte[] iv = cipher.getIV();
            byte[] encrypted = cipher.doFinal(value.getBytes(StandardCharsets.UTF_8));

            byte[] packed = new byte[iv.length + encrypted.length];
            System.arraycopy(iv, 0, packed, 0, iv.length);
            System.arraycopy(encrypted, 0, packed, iv.length, encrypted.length);

            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_NAME, Base64.encodeToString(packed, Base64.NO_WRAP))
                .apply();
            return true;
        } catch (Exception e) {
            Log.e(TAG, "saveApiKey failed: " + e.getMessage());
            return false;
        }
    }

    public static void clearApiKey() {
        Context context = qtContext();
        if (context == null) return;
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .remove(KEY_NAME)
            .apply();
    }

    // ─── Mic permission ────────────────────────────────────────
    public static boolean hasRecordPermission() {
        Context context = qtContext();
        return context != null
            && context.checkSelfPermission(Manifest.permission.RECORD_AUDIO)
                == PackageManager.PERMISSION_GRANTED;
    }

    public static void requestRecordPermission() {
        try {
            android.app.Activity activity = org.qtproject.qt.android.QtNative.activity();
            if (activity != null) {
                activity.requestPermissions(
                    new String[]{Manifest.permission.RECORD_AUDIO}, 4101);
            }
        } catch (Exception ignored) {}
    }

    // ─── TTS (async-safe) ──────────────────────────────────────
    public static void speak(String text, String localeTag) {
        if (text == null || text.trim().isEmpty()) return;

        Context context = qtContext();
        if (context == null) return;

        if (tts == null) {
            pendingSpeakText = text;
            pendingSpeakLocale = localeTag;
            tts = new TextToSpeech(context.getApplicationContext(), status -> {
                if (status == TextToSpeech.SUCCESS) {
                    ttsReady = true;
                    tts.setOnUtteranceProgressListener(new UtteranceProgressListener() {
                        public void onStart(String id) {}
                        public void onDone(String id) { nativeTtsDone(); }
                        public void onError(String id) { nativeTtsDone(); }
                    });
                    if (pendingSpeakText != null) {
                        String t = pendingSpeakText;
                        String l = pendingSpeakLocale;
                        pendingSpeakText = null;
                        pendingSpeakLocale = null;
                        speak(t, l);
                    }
                } else {
                    Log.e(TAG, "TTS init failed: " + status);
                    nativeTtsDone();
                }
            });
            return;
        }

        if (!ttsReady) {
            pendingSpeakText = text;
            pendingSpeakLocale = localeTag;
            return;
        }

        Locale requested = Locale.forLanguageTag(
            localeTag == null ? "fa-IR" : localeTag);
        int result = tts.setLanguage(requested);
        if (result == TextToSpeech.LANG_MISSING_DATA
            || result == TextToSpeech.LANG_NOT_SUPPORTED) {
            tts.setLanguage(Locale.ENGLISH);
        }
        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "MRT1_JARVIS");
    }

    // ─── Speech Recognition ────────────────────────────────────
    public static void startListening(String localeTag) {
        Context context = qtContext();
        if (context == null) {
            nativeResult("ERROR: Android context unavailable");
            return;
        }
        if (!SpeechRecognizer.isRecognitionAvailable(context)) {
            nativeResult("ERROR: Speech recognition unavailable");
            return;
        }

        if (recognizer != null) {
            recognizer.destroy();
            recognizer = null;
        }
        recognizer = SpeechRecognizer.createSpeechRecognizer(
            context.getApplicationContext());

        recognizer.setRecognitionListener(new RecognitionListener() {
            public void onReadyForSpeech(Bundle p) {}
            public void onBeginningOfSpeech() {}
            public void onRmsChanged(float rmsdB) {}
            public void onBufferReceived(byte[] b) {}
            public void onEndOfSpeech() {}
            public void onError(int error) { nativeResult("ERROR:" + error); }
            public void onResults(Bundle results) {
                ArrayList<String> values =
                    results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                nativeResult(values != null && !values.isEmpty() ? values.get(0) : "");
            }
            public void onPartialResults(Bundle results) {}
            public void onEvent(int type, Bundle params) {}
        });

        String locale = localeTag == null ? "fa-IR" : localeTag;
        Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, locale);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, locale);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                        RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        recognizer.startListening(intent);
    }

    public static void stopListening() {
        if (recognizer != null) recognizer.stopListening();
    }

    private static native void nativeResult(String text);
    private static native void nativeTtsDone();
}
