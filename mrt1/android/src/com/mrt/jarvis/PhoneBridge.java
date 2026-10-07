package com.mrt.jarvis;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.telephony.TelephonyManager;

public final class PhoneBridge {
    private PhoneBridge() {}

    public static boolean hasPhonePermission(Context context) {
        return context.checkSelfPermission(Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED;
    }

    public static void requestPhonePermission() {
        try {
            android.app.Activity activity = org.qtproject.qt.android.QtNative.activity();
            if (activity != null) {
                activity.requestPermissions(new String[] {
                    Manifest.permission.READ_PHONE_STATE,
                    Manifest.permission.CALL_PHONE,
                    Manifest.permission.READ_CALL_LOG
                }, 4201);
            }
        } catch (Exception ignored) {}
    }

    public static int getPhoneState(Context context) {
        if (!hasPhonePermission(context)) return TelephonyManager.CALL_STATE_IDLE;
        TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
        return tm != null ? tm.getCallState() : TelephonyManager.CALL_STATE_IDLE;
    }
}
