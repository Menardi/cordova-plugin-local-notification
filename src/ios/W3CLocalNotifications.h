//
//  W3CLocalNotifications.h
//

#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface W3CLocalNotifications : CDVPlugin
{
    NSDictionary *notificationMessage;
    NSString *notificationCallbackId;
}

@property (nonatomic, copy) NSString *callbackId;

- (void)show:(CDVInvokedUrlCommand*)command;
- (void)close:(CDVInvokedUrlCommand*)command;
- (void)requestPermission:(CDVInvokedUrlCommand*)command;
- (void)hasPermission:(CDVInvokedUrlCommand*)command;
- (void)notificationClicked;
- (void)deviceready;
- (void)openPermissionScreen:(CDVInvokedUrlCommand*)command;

@end
