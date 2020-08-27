package com.adobe.phonegap.notification;

import android.app.Activity;
import androidx.core.app.NotificationManagerCompat;
import android.content.Intent;
import android.os.Bundle;
import android.net.Uri;

import com.syncostyle.onethingchristmas.MainActivity;

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
        Intent receivedIntent = getIntent();
        Bundle extras = receivedIntent.getExtras();
        String tag = extras.getString("tag", "");

        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(getApplicationContext());
        notificationManager.cancel(tag, 0);

        String url = extras.getString("url", "");

        Intent intent;
        if(url.length() > 0) {
            Uri uri = Uri.parse(url);
            intent = new Intent(Intent.ACTION_VIEW, uri);
        } else {
            intent = new Intent(getApplicationContext(), MainActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            intent.putExtra("notificationTag", tag);
        }

        startActivity(intent);

        finish();
    }
}
