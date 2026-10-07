package com.mrt.jarvis;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import java.util.ArrayList;
import java.util.Locale;

public final class SpeechBridge {
    private static SpeechRecognizer recognizer;
    private static TextToSpeech tts;

    private SpeechBridge() {}

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
