
# phonegap-plugin-local-notification

> Only currently tested on Android, API may change without warning. Use at your own risk!

A work-in-progress fork of `phonegap-plugin-local-notification` which allows for scheduling of notifications.

## Usage

### LocalNotifications.create(options)

Create a notification by passing in either an `options` object which defines a notification, or an array of `options` objects.

#### The options object

```
{
    title: '',     // (String) [Required]
    body: '',      // (String)
    tag: '',       // (String) A unique id for the notification. Can be used to reference it later.
    smallIcon: '', // (Path) [Required on Android] Path to a small icon for use on Android
    sound: '',     // (Path) The sound to play when the notification is shown. If not specified, default is used
    when: 0,       // (Date or timestamp) When the notification should be shown. If not specified, shows immediately
}
```

Paths on Android currently supported using files in your `res` folder. Icons must be in a `drawable` folder, and sounds must be in `raw`. Then refer to them with `res://` at the beginning, and _without the file extension_. For example:

```
{
    smallIcon: 'res://my_small_icon',
    sound: 'res://my_notification_sound
}
```

### LocalNotifications.cancel({ tag: String })

Cancel a schedule notification by passing in the tag that was used to originally schedule it.

### LocalNotifications.hasPermission(callback)

Check if the user has allowed notifications for this app. The callback will be passed one argument, `true` is granted and `false` otherwise.

### LocalNotifications.requestPermission(callback)

Request the user to enable the notifications permission.

### LocalNotifications.settings()

Open the settings screen where the user can manually grant notification permission.

## Handling events

When a notification is tapped, the `notificationclick` event is fired on the `document`. The notification's tag is passed under the `detail` object in the callback's event argument.

```
document.addEventListener('notificationclick', function(ev) {
    console.log('Notification clicked: ' + ev.detail.tag);
});
```