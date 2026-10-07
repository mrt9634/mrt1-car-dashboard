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

    public static String loadApiKey(Context context) {
        try {
            android.content.SharedPreferences p = context.getSharedPreferences("mrt1_secure", Context.MODE_PRIVATE);
            String packed = p.getString("openai_key", "");
            if (packed.isEmpty()) return "";
            byte[] all = Base64.decode(packed, Base64.DEFAULT);
            byte[] iv = new byte[12];
            System.arraycopy(all, 0, iv, 0, iv.length);
            byte[] cipherText = new byte[all.length - iv.length];
            System.arraycopy(all, iv.length, cipherText, 0, cipherText.length);
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.DECRYPT_MODE, getKey(), new GCMParameterSpec(128, iv));
            return new String(cipher.doFinal(cipherText), StandardCharsets.UTF_8);
        } catch (Exception e) { return ""; }
    }

    public static boolean saveApiKey(Context context, String value) {
        try {
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.ENCRYPT_MODE, getKey());
            byte[] iv = cipher.getIV();
            byte[] encrypted = cipher.doFinal(value.getBytes(StandardCharsets.UTF_8));
            byte[] packed = new byte[iv.length + encrypted.length];
            System.arraycopy(iv, 0, packed, 0, iv.length);
            System.arraycopy(encrypted, 0, packed, iv.length, encrypted.length);
            context.getSharedPreferences("mrt1_secure", Context.MODE_PRIVATE).edit()
                    .putString("openai_key", Base64.encodeToString(packed, Base64.NO_WRAP)).apply();
            return true;
        } catch (Exception e) { return false; }
    }

    public static void clearApiKey(Context context) {
        context.getSharedPreferences("mrt1_secure", Context.MODE_PRIVATE).edit().remove("openai_key").apply();
    }

    public static boolean hasRecordPermission(Context context) {
        return context.checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED;
    }

    public static void requestRecordPermission(Context context) {
        if (context instanceof android.app.Activity) {
            ((android.app.Activity) context).requestPermissions(new String[]{Manifest.permission.RECORD_AUDIO}, 4101);
        }
    }

    public static void speak(Context context, String text, String localeTag) {
        if (tts == null) tts = new TextToSpeech(context.getApplicationContext(), status -> {});
        Locale locale = Locale.forLanguageTag(localeTag == null ? "fa-IR" : localeTag);
        tts.setLanguage(locale);
        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "MRT1_JARVIS");
    }

    public static void startListening(Context context, String localeTag) {
        if (!SpeechRecognizer.isRecognitionAvailable(context)) {
            nativeResult("ERROR: Speech recognition unavailable");
            return;
        }
        if (recognizer != null) recognizer.destroy();
        recognizer = SpeechRecognizer.createSpeechRecognizer(context.getApplicationContext());
        recognizer.setRecognitionListener(new RecognitionListener() {
            public void onReadyForSpeech(Bundle p) {}
            public void onBeginningOfSpeech() {}
            public void onRmsChanged(float rmsdB) {}
            public void onBufferReceived(byte[] b) {}
            public void onEndOfSpeech() {}
            public void onError(int error) { nativeResult("ERROR:" + error); }
            public void onResults(Bundle results) {
                ArrayList<String> values = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                nativeResult(values != null && !values.isEmpty() ? values.get(0) : "");
            }
            public void onPartialResults(Bundle results) {}
            public void onEvent(int type, Bundle params) {}
        });
        Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, localeTag == null ? "fa-IR" : localeTag);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, localeTag == null ? "fa-IR" : localeTag);
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        recognizer.startListening(intent);
    }

    public static void stopListening() {
        if (recognizer != null) recognizer.stopListening();
    }

    private static native void nativeResult(String text);
}
