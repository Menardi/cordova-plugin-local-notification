/* global cordova:false */
/* globals window */

var exec = cordova.require('cordova/exec');

/**
 * @description Create one or more notifications
 * @param options An options object to customise the notification
 */

var Notification = function(title, options) {
    if(typeof title === 'undefined') {
        throw new Error('Title is required for Notification');
    }

    this.options = {
        tag: options.tag || '',
        title: title,
        body: options.body || '',
        icon: options.icon || '',
        sound: options.sound || '',
        url: options.url || ''
    };

    if(options.timestamp instanceof Date) {
        this.options.timestamp = options.timestamp.getTime();
    } else {
        this.options.timestamp = options.timestamp || 0;
    }

    // this.permission = 'granted';
    this.onclick = function() {};
    this.onshow = function() {};
    this.onerror = function() {};
    this.onclose = function() {};

    // triggered on click, show, error and close
    var that = this;
    var success = function(result) {
        if (!result) {
            return;
        }
        if (result === 'show') {
            that.onshow();
        } else if (result === 'click') {
            that.onclick();
        }
    };
    var failure = function() {
        that.onerror();
    };

    exec(success, failure, 'Notifications', 'show', [this.options.tag, this.options.title, this.options.body, this.options.timestamp, this.options.icon, this.options.sound, this.options.url]);
}

/**
 * @description requests permission from the user to show a local notification.
 * @function requestPermission
 * @memberof Notification
 * @param {!callback} callback - See type definition.
 */
Notification.requestPermission = function(callback) {
    if (!callback) { callback = function() {}; }

    if (typeof callback !== 'function')  {
        console.log('Notification.requestPermission failure: callback parameter not a function');
        return;
    }

    exec(callback, function() {
        console.log('requestPermission error');
    }, 'Notifications', 'requestPermission', [{}]);
};


/**
 * @description Closes an existing notification
 * @function close
 * @memberof Notification
 * @param {!string} tag of the local notification.
 */
Notification.close = function(tag) {
    exec(function() {}, function() {}, 'Notifications', 'close', [tag]);
};

//
// The functions below are not part of the spec
//

/**
 * @description checks if app has permission to show a local notification.
 * @function hasPermission
 * @memberof Notification
 * @param {!callback} callback - See type definition.
 */
Notification.hasPermission = function(callback) {
    if (!callback) { callback = function() {}; }

    if (typeof callback !== 'function')  {
        console.log('Notification.hasPermission failure: callback parameter not a function');
        return;
    }

    exec(function(status) { callback(status) }, function() { console.log('hasPermission error') }, 'Notifications', 'hasPermission', [{}]);
};

Notification.openPermissionScreen = function() {
    exec(function() {}, function() {
        console.log('openPermissionScreen error');
    }, 'Notifications', 'openPermissionScreen', [{}]);
};

Notification._triggerEvent = function(eventName, data) {
    // TODO: Handle events internally
    data = data || {};
    document.dispatchEvent(new CustomEvent(eventName, { detail: data }));
}

exec(function(data) {
        var event = new CustomEvent("notification", { detail: data });
        document.dispatchEvent(event);
    }, function(e) {
        console.log("LISTEN ERROR: ", e);
    }, 'Notifications', 'listen', [{}]
);

document.addEventListener('deviceready', function() {
    exec(function() {}, function() {}, 'Notifications', 'deviceready', []);
});

/**
 * @description A callback to be used when the requestPermission method returns a value.
 *
 * @callback callback
 * @param {string} permission - one of "default", "denied" or "granted"
 */

module.exports = Notification;