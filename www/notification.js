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
    var getValue = argscheck.getValue;

    this.permission = 'granted';
    this.title = getValue(title, '');
    this.dir = getValue(options.dir, 'auto');
    this.lang = getValue(options.lang, '');
    this.body = getValue(options.body, '');
    this.tag = getValue(options.tag, '');
    this.icon = getValue(options.icon, '');
    this.sound = getValue(options.sound, '');
    this.when = getValue(options.when, '0');
    this.url = getValue(options.url, '');
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

    exec(success, failure, 'LocalNotifications', 'show', [this.title, this.dir, this.lang, this.body, this.tag, this.icon, this.sound, this.when, this.url]);
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
    }, 'LocalNotifications', 'requestPermission', []);
};


LocalNotification.settings = function() {
    exec(function() {}, function() {
        console.log('settings error');
    }, 'LocalNotifications', 'settings', []);
};

/**
  * @description closes an open notification.
  * @function close
  * @memberof LocalNotification
  */
LocalNotification.prototype.close = function() {
    var that = this;
    exec(function() {
        that.onclose();
    }, function() {
        that.onerror();
    }, 'LocalNotifications', 'close', [this.tag]);
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
    }, 'LocalNotifications', 'close', [tag]);
};

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
