
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
import android.provider.Settings;
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
import android.net.Uri;
import java.util.Random;
import android.os.Build;

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
        Context context = cordova.getActivity();
        if (action.equals("show")) {
            Log.d(TAG, "action show");
            notificationContext = callbackContext;
            showNotification(args);
            PluginResult result = new PluginResult(PluginResult.Status.OK, "show");
            result.setKeepCallback(true);
            notificationContext.sendPluginResult(result);
        } else if (action.equals("close")) {
            Log.d(TAG, "action close");
            String tag = args.getString(0);
            NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            mNotificationManager.cancel(tag, 0);
            AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            Intent notificationBroadcastReceiverIntent = new Intent(context, NotificationBroadcastReceiver.class);
            int requestCode = tag.hashCode();
            PendingIntent pendingIntent = PendingIntent.getBroadcast(context, requestCode, notificationBroadcastReceiverIntent, PendingIntent.FLAG_NO_CREATE);
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent);
                pendingIntent.cancel();
                Log.d(TAG, "alarm cancelled: "+requestCode);
            } else {
                Log.d(TAG, "alarm not found: "+requestCode);
            }
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
        } else if (action.equals("requestPermission")) {
            NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            if (mNotificationManager.areNotificationsEnabled()) {
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, "granted"));
            } else {
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, "denied"));
            }
        } else if (action.equals("settings")) {
            Intent intent = new Intent();
            if(Build.VERSION.SDK_INT > Build.VERSION_CODES.N_MR1){
                intent.setAction("android.settings.APP_NOTIFICATION_SETTINGS");
                intent.putExtra("android.provider.extra.APP_PACKAGE", context.getPackageName());
            } else if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP){
                intent.setAction("android.settings.APP_NOTIFICATION_SETTINGS");
                intent.putExtra("app_package", context.getPackageName());
                intent.putExtra("app_uid", context.getApplicationInfo().uid);
            } else {
                intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                intent.addCategory(Intent.CATEGORY_DEFAULT);
                intent.setData(Uri.parse("package:" + context.getPackageName()));
            }
            context.startActivity(intent);
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
        String tag = args.getString(4);
        int requestCode = tag.hashCode();
        Intent notificationBroadcastReceiverIntent = new Intent(context, NotificationBroadcastReceiver.class);
        notificationBroadcastReceiverIntent.putExtra("args", args.toString());
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, requestCode, notificationBroadcastReceiverIntent, PendingIntent.FLAG_CANCEL_CURRENT);
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, when, pendingIntent);
    }
}
