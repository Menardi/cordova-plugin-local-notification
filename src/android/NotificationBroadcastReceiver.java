
package com.adobe.phonegap.notification;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONObject;
import org.json.JSONException;

import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.app.Notification;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.support.v4.app.NotificationManagerCompat;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import android.util.Base64;
import android.os.Parcelable;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.ByteArrayOutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Random;
import android.content.BroadcastReceiver;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import java.util.List;


public class NotificationBroadcastReceiver extends BroadcastReceiver {

    private static final String TAG = "LocalNotifications";

    @Override
    public void onReceive(final Context context, final Intent intent) {
        new Thread(new Runnable(){
            @Override
            public void run() {
                startNotification(context, intent);
            }
        }).start();
    }

    public void startNotification(final Context context, Intent intent) {
        Resources resources = context.getResources();

        String title = intent.getStringExtra("title");
        String body = intent.getStringExtra("body");
        String tag = intent.getStringExtra("tag");
        String icon = intent.getStringExtra("icon");
        String sound = intent.getStringExtra("sound");
        String url = intent.getStringExtra("url");

        Log.v(TAG, "show notification now=" + System.currentTimeMillis() + " title=" + title);
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
        int requestCode = new Random().nextInt();

        Intent notificationIntent = new Intent(context, NotificationHandlerActivity.class);
        notificationIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        notificationIntent.putExtra("tag", tag);
        notificationIntent.putExtra("url", url);

        PendingIntent contentIntent = PendingIntent.getActivity(context, requestCode, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        int smallIconRes;
        if (icon.startsWith("res://")) {
            String iconId = icon.replaceFirst("res://", "");
            Log.v(TAG, "Using small icon: " + iconId);
            smallIconRes = resources.getIdentifier(iconId, "drawable", context.getPackageName());
        } else {
            smallIconRes = resources.getIdentifier("ic_statusbar_icon", "drawable", context.getPackageName());
        }

        Uri soundUri;
        if (sound.startsWith("res://")) {
            String soundId = sound.replaceFirst("res://", "");
            Log.v(TAG, "Sound file: " + soundId);
            int soundResId = resources.getIdentifier(soundId, "raw", context.getPackageName());
            soundUri = Uri.parse("android.resource://" + context.getPackageName() + "/" + soundResId);
        } else {
            soundUri = android.provider.Settings.System.DEFAULT_NOTIFICATION_URI;
        }

        // Build notifications
        NotificationCompat.Builder mBuilder =
            new NotificationCompat.Builder(context)
                .setWhen(System.currentTimeMillis())
                .setContentTitle(title)
                .setContentText(body)
                .setSmallIcon(smallIconRes)
                .setContentIntent(contentIntent)
                .setAutoCancel(true)
                .setSound(soundUri);

        Notification notification = mBuilder.build();
        notificationManager.notify(tag, 0, notification);
    }
}
