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
    private static SpeechRecognizer recognizer;
    private static TextToSpeech tts;
    private static final String KEYSTORE = "AndroidKeyStore";
    private static final String KEY_ALIAS = "MRT1_OpenAI_Key";
    private SpeechBridge() {}

    private static Context qtContext() {
        android.app.Activity activity = org.qtproject.qt.android.QtNative.activity();
        return activity != null ? activity : null;
    }

    private static SecretKey getKey() throws Exception {
        KeyStore ks = KeyStore.getInstance(KEYSTORE);
        ks.load(null);
        if (!ks.containsAlias(KEY_ALIAS)) {
            KeyGenerator kg = KeyGenerator.getInstance("AES", KEYSTORE);
            kg.init(256);
            kg.generateKey();
        }
        return ((KeyStore.SecretKeyEntry) ks.getEntry(KEY_ALIAS, null)).getSecretKey();
    }

    public static String loadApiKey() {
        try {
            Context context = qtContext();
            if (context == null) return "";
            String packed = context.getSharedPreferences("mrt1_secure", Context.MODE_PRIVATE)
                .getString("openai_key", "");
            if (packed.isEmpty()) return "";

            byte[] all = Base64.decode(packed, Base64.DEFAULT);
            if (all.length < 13) return "";

            byte[] iv = new byte[12];
            System.arraycopy(all, 0, iv, 0, 12);
            byte[] cipherText = new byte[all.length - 12];
            System.arraycopy(all, 12, cipherText, 0, cipherText.length);

            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.DECRYPT_MODE, getKey(), new GCMParameterSpec(128, iv));
            return new String(cipher.doFinal(cipherText), StandardCharsets.UTF_8);
        } catch (Exception e) {
            return "";
        }
    }

    public static boolean saveApiKey(String value) {
        try {
            Context context = qtContext();
            if (context == null) return false;

            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.ENCRYPT_MODE, getKey());
            byte[] iv = cipher.getIV();
            byte[] encrypted = cipher.doFinal(value.getBytes(StandardCharsets.UTF_8));

            byte[] packed = new byte[iv.length + encrypted.length];
            System.arraycopy(iv, 0, packed, 0, iv.length);
            System.arraycopy(encrypted, 0, packed, iv.length, encrypted.length);

            context.getSharedPreferences("mrt1_secure", Context.MODE_PRIVATE)
                .edit()
                .putString("openai_key", Base64.encodeToString(packed, Base64.NO_WRAP))
                .apply();
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static void clearApiKey() {
        Context context = qtContext();
        if (context == null) return;
        context.getSharedPreferences("mrt1_secure", Context.MODE_PRIVATE)
            .edit()
            .remove("openai_key")
            .apply();
    }

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

    public static void speak(String text, String localeTag) {
        Context context = qtContext();
        if (context == null) return;

        if (tts == null) {
            tts = new TextToSpeech(context.getApplicationContext(), status -> {});
            tts.setOnUtteranceProgressListener(new UtteranceProgressListener() {
                public void onStart(String id) {}
                public void onDone(String id) { nativeTtsDone(); }
                public void onError(String id) { nativeTtsDone(); }
            });
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

        if (recognizer != null) recognizer.destroy();
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
        intent.putExtra(
            RecognizerIntent.EXTRA_LANGUAGE_MODEL,
            RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        recognizer.startListening(intent);
    }

    public static void stopListening() {
        if (recognizer != null) recognizer.stopListening();
    }

    private static native void nativeResult(String text);
    private static native void nativeTtsDone();
}
