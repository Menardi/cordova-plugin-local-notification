
package com.adobe.phonegap.notification;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import android.annotation.SuppressLint;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.AlarmManager;
import android.app.Notification;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import android.util.Base64;
import android.os.Parcelable;
import java.io.IOException;
import java.io.InputStream;
import java.io.ByteArrayOutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Random;

/**
* This class exposes methods in Cordova that can be called from JavaScript.
*/
public class LocalNotifications extends CordovaPlugin {

    private static final String TAG = "LocalNotifications";

    private static CallbackContext notificationContext;

     /**
     * Executes the request and returns PluginResult.
     *
     * @param action            The action to execute.
     * @param args              JSONArry of arguments for the plugin.
     * @param callbackContext   The callback context from which we were invoked.
     */
    @SuppressLint("NewApi")
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        Log.d(TAG, "in local notifications");

        if (action.equals("show")) {
            Log.d(TAG, "action show");
            notificationContext = callbackContext;
            showNotification(args);
            PluginResult result = new PluginResult(PluginResult.Status.OK, "show");
            result.setKeepCallback(true);
            notificationContext.sendPluginResult(result);
        } else if (action.equals("close")) {
            NotificationManager mNotificationManager = (NotificationManager) cordova.getActivity().getSystemService(Context.NOTIFICATION_SERVICE);
            mNotificationManager.cancel(args.getString(0), 0);
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
        } else if (action.equals("requestPermission")) {
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, "granted"));
        } else {
            Log.d(TAG, "return false");
            return false;
        }
        return true;
    }

    private void showNotification(JSONArray args) throws JSONException {
        // Get args
        long when = args.getLong(7);
        if (when == 0) {
            when = System.currentTimeMillis();
        }
        Context context = cordova.getActivity();
        int requestCode = new Random().nextInt();
        Intent notificationBroadcastReceiverIntent = new Intent(context, NotificationBroadcastReceiver.class);
        notificationBroadcastReceiverIntent.putExtra("args", args.toString());
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, requestCode, notificationBroadcastReceiverIntent, PendingIntent.FLAG_CANCEL_CURRENT);
        Log.v(TAG, "PENDING INTENT NOW: "+pendingIntent);
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, when, pendingIntent);
    }


    public static void fireClickEvent(String tag) {
        PluginResult result = new PluginResult(PluginResult.Status.OK, "click");
        result.setKeepCallback(true);
        notificationContext.sendPluginResult(result);
    }
}
