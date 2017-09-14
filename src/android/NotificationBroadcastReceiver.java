
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
        try {
            JSONArray args = new JSONArray(intent.getStringExtra("args"));
            String title = args.getString(0);
            String dir = args.getString(1);
            String lang = args.getString(2);
            String body = args.getString(3);
            String tag = args.getString(4);
            String icon = args.getString(5);
            String sound = args.getString(6);
            long when = args.getLong(7);
            String url = args.getString(8);

            Log.v(TAG, "now="+System.currentTimeMillis() + " args="+args.toString());
            NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            int requestCode = new Random().nextInt();
            Intent notificationIntent = new Intent(context, NotificationHandlerActivity.class);
            notificationIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
            notificationIntent.putExtra("tag", tag);
            notificationIntent.putExtra("url", url);
            PendingIntent contentIntent = PendingIntent.getActivity(context, requestCode, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);
            int smallIcon = context.getResources().getIdentifier("ic_statusbar_icon", "drawable", context.getPackageName());
            String soundUrl = getMP3DataURIFromURL(sound);
            // Build notifications
            NotificationCompat.Builder mBuilder =
                new NotificationCompat.Builder(context)
                    .setWhen(System.currentTimeMillis())
                    .setContentTitle(title)
                    .setContentText(body)
                    .setSmallIcon(smallIcon)
                    .setVibrate(new long[]{100, 200, 100, 500})
                    .setContentIntent(contentIntent)
                    .setAutoCancel(true);

            if (soundUrl != null) {
                mBuilder.setSound(android.net.Uri.parse(soundUrl));
            } else {
                mBuilder.setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI);
            }
            if (icon.startsWith("http://") || icon.startsWith("https://")) {
                Bitmap bitmap = getBitmapFromURL(icon);
                mBuilder.setLargeIcon(bitmap);
            }
            Notification notification = mBuilder.build();
            notificationManager.notify(tag, 0, notification);
        } catch (JSONException e) {
            Log.v(TAG, "JSON ERROR: "+e);
        }
    }

    private Bitmap getBitmapFromURL(String strURL) {
        try {
            URL url = new URL(strURL);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(15000);
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            return BitmapFactory.decodeStream(input);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    private String getMP3DataURIFromURL(String strURL) {
        try {
            URL url = new URL(strURL);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(15000);
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            byte[] data = new byte[1024];
            int current = 0;
            while((current = input.read(data, 0, data.length)) != -1){
               buffer.write(data,0,current);
            }
            String encoded = Base64.encodeToString(buffer.toByteArray(), Base64.DEFAULT);
            return "data:audio/mpeg;base64," + encoded;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}
