
# phonegap-plugin-local-notification

> Only currently tested on Android 4.4+, API may change without warning. Use at your own risk!

A work-in-progress fork of `phonegap-plugin-local-notification` which allows for scheduling of notifications. It is loosely based on the [W3C Notifications Spec](https://www.w3.org/TR/notifications/), but adds scheduling of notifications. It also adds some permission-handling functions which are not part of the spec.

## Usage

### Notification(title, options)

Create a notification by passing in the title (String), and an optional options object.

```
var notification = new Notification('My Notification', {});
```

#### The options object

The options object is used to customise your notification.

```
{
    tag: '',
    body: '',
    icon: '',
    timestamp: 0,
    sound: '',
    url: ''
}
```

##### options.tag (String)

The tag is an ID which can be used to reference the notification. For example, after scheduling a notification, you can cancel it by calling `Notification.cancel(tag)`. You should always set a tag, or else you will not be able to reference it later.

##### options.body (String)

The main body of the notification. For example, for a messaging app, this would normally be the contents of the message, whereas the sender would be the title.

##### options.icon (String) [Required on Android]

On Android, this is the icon that shows in the notification bar (the `smallIcon`). It **must** be in your `res/drawable` folders, and cannot be from anywhere else. On Android, the icon should be referenced without its extension, and with `res://` in front to show that it is in your res folder. For example, if you have an icon called `mynotification.png`, then this option should be `icon: 'res://mynotification`.

##### options.timestamp (Number or Date)

In the W3C spec, this is supposed to be used to show the time the notification refers to (such as an upcoming event). However, in this plugin, it is used to schedule the notification. The time can be either a unix-style timestamp, or a Date object.

```
time: Date.now() + 60000 // in one minute
time: new Date('2020-01-01T08:00:00') // 8am on 1/1/2020
```

##### options.sound (String) [Not in spec]

The sound to play when the notification is shown. On Android, this must be in your `res/raw` folder, and referenced similarly to the icon above -- `mynotification.mp3` would be `sound: 'res://mynotification`. If not specified, the system default sound will be used.

##### options.url (String) [Not in spec]

If specified, tapping the notification will open this URL rather than opening the app. Ensure that it is prepended with the protocol (`http://` or `https://`).

### Notification.close({ tag: String })

Close a notification. If it is already shown, it will be dismissed. If it is scheduled for the future, it will be unscheduled. Pass in the tag that was used to originally schedule it.

```
var notification = Notification('Close this', { tag: 'n1' });

// Both of these do the same thing
notification.close();
Notification.close('n1');
```

### Notification.requestPermission(callback)

Request the user to enable the notifications permission. This will bring up the permissions dialog if necessary. The callback will return the result as a string, either `granted` or `denied`.

```
Notification.requestPermission(function(status) {
    if(status === 'granted') {
        // Ready to use notifications
    } else {
        // Permission was denied
    }
});
```

### Notification.hasPermission(callback) [Not in spec]

Check if the user has allowed notifications for this app. The callback will be passed one argument, `true` is granted and `false` otherwise.

```
Notification.hasPermission(function(status) {
    if(status === 'granted') {
        // Ready to use notifications
    } else {
        // Permission was denied
    }
});
```

### Notification.openPermissionScreen() [Not in spec]

Open the screen where the user can manually grant notification permission.

## Handling events

The spec describes several event callbacks, such as `onclick`, but they are not implemented in this plugin. This is because these callbacks assume you always have a reference to the notification, which is not always the case if you are scheduling notifications for the future. Instead, a global `notificationclick` event is fired, with the `tag` included so you can determine which notification it refers to.

```
document.addEventListener('notificationclick', function(ev) {
    console.log('Notification clicked: ' + ev.detail.tag);
});
```