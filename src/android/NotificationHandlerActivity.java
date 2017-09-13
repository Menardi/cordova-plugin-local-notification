package com.adobe.phonegap.notification;

import android.app.Activity;
import android.app.NotificationManager;
import android.app.Notification;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.support.v4.app.RemoteInput;
import android.content.BroadcastReceiver;
import android.net.Uri;

 public class NotificationHandlerActivity extends Activity {
    private static String LOG_TAG = "LocalNotification_PushHandlerActivity";

    /*
     * this activity will be started if the user touches a notification that we own.
     * We send it's data off to the push plugin for processing.
     * If needed, we boot up the main activity to kickstart the application.
     * @see android.app.Activity#onCreate(android.os.Bundle)
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        Bundle extras = intent.getExtras();
        String tag = extras.getString("tag", "");
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(tag, 0);
        String url = extras.getString("url", "");
        Uri uri = Uri.parse(url); // missing 'http://' will cause crashed
        Intent intent2 = new Intent(Intent.ACTION_VIEW, uri);
        startActivity(intent2);
        finish();
    }
}
