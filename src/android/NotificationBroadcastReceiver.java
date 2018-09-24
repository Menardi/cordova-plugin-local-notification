
package com.adobe.phonegap.notification;

import org.json.JSONObject;
import org.json.JSONException;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Notification;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.media.AudioAttributes;
import android.net.Uri;
import android.os.Build;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import java.util.Random;
import android.content.BroadcastReceiver;

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
        String channelId = intent.getStringExtra("channelId");
        String channelName = intent.getStringExtra("channelName");
        String channelDescription = intent.getStringExtra("channelDescription");

        Log.v(TAG, "show notification now=" + System.currentTimeMillis() + " title=" + title);
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

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

        if(Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            NotificationChannel mChannel = new NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT);

            if(channelDescription.length() > 0) {
                mChannel.setDescription(channelDescription);
            }

            AudioAttributes audioAttributes = new AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .build();

            mChannel.setSound(soundUri, audioAttributes);

            notificationManager.createNotificationChannel(mChannel);
        }

        // Build notifications
        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(context, channelId)
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
