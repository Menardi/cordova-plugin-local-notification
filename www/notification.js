/* global cordova:false */
/* globals window */

var argscheck = cordova.require('cordova/argscheck'),
    exec = cordova.require('cordova/exec'),
    utils = cordova.require('cordova/utils');

/**
 *  @description A global object that lets you interact with the LocalNotification API.
 *  @global
 *  @param {!string} title of the local notification.
 *  @param {?Options} options An object containing optional property/value pairs.
 */
var LocalNotification = function(title, options) {
    // require title parameter
    if (typeof title === 'undefined') {
        throw new Error('The title argument is required.');
    }
    options = options || {};
    options.title = options.title || title;
    options.dir = options.dir || 'auto';
    options.body = options.body || '';
    options.lang = options.lang || '';
    options.tag = options.tag || '';
    options.icon = options.icon || '';
    options.sound = options.sound || '';
    options.url = options.url || '';
    options.when = options.when || 0;

    this.permission = 'granted';
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
    exec(success, failure, 'LocalNotifications', 'show', [options]);
};

/**
  * @description requests permission from the user to show a local notification.
  * @function requestPermission
  * @memberof LocalNotification
  * @param {!callback} callback - See type definition.
  */
LocalNotification.requestPermission = function(callback) {
    if (!callback) { callback = function() {}; }

    if (typeof callback !== 'function')  {
        console.log('LocalNotification.requestPermission failure: callback parameter not a function');
        return;
    }

    exec(callback, function() {
        console.log('requestPermission error');
    }, 'LocalNotifications', 'requestPermission', [{}]);
};


LocalNotification.settings = function() {
    exec(function() {}, function() {
        console.log('settings error');
    }, 'LocalNotifications', 'settings', [{}]);
};

/**
  * @description requests permission from the user to show a local notification.
  * @function cancel
  * @memberof LocalNotification
  * @param {!string} tag of the local notification.
  */
LocalNotification.cancel = function(tag) {
    exec(function() {
    }, function() {
    }, 'LocalNotifications', 'close', [{tag: tag}]);
};

exec(function(data) {
        var event = new CustomEvent("localnotification", { detail: data });
        document.dispatchEvent(event);
    }, function(e) {
        console.log("LISTEN ERROR: ", e);
    }, 'LocalNotifications', 'listen', [{}]
);

/**
 * @description A callback to be used when the requestPermission method returns a value.
 *
 * @callback callback
 * @param {string} permission - one of "default", "denied" or "granted"
 */

/*
 * @typedef {Object} Options - An object for configuring LocalNotification behavior.
 * @property {string} [dir='auto'] - Sets the direction of the notification. One of "auto", "ltr" or "rtl"
 * @property {string} [lang=''] - Sets the language of the notification
 * @property {string} [body=''] - Sets the body of the notification
 * @property {string} [tag=''] - Sets the identifying tag of the notification
 * @property {string} [icon=''] - Sets the icon of the notification
 */

module.exports = LocalNotification;
