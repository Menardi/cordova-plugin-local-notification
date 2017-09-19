
@import UserNotifications;

#import <Cordova/CDV.h>
#import "W3CLocalNotifications.h"

@implementation W3CLocalNotifications : CDVPlugin

@synthesize callbackId;

- (void)show:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = [command.arguments objectAtIndex:0];
    content.body = [command.arguments objectAtIndex:3];
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{@"deep_link_action": [command.arguments objectAtIndex:8]};
    [content setValue:@YES forKey:@"shouldAlwaysAlertWhileAppIsForeground"];
    NSString *identifier = [command.arguments objectAtIndex:4];

    double ms = [[command.arguments objectAtIndex:7] doubleValue];
    NSDate *when = [NSDate dateWithTimeIntervalSince1970:ms / 1000.0];
    //NSISO8601DateFormatter *dateFormatter = [[NSISO8601DateFormatter alloc] init];
    //NSLog(@"Notification set at: %@",[dateFormatter stringFromDate:when]);
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *date = [calendar components:(NSYearCalendarUnit  |
                                                     NSMonthCalendarUnit |
                                                     NSDayCalendarUnit   |
                                                     NSHourCalendarUnit  |
                                                     NSMinuteCalendarUnit|
                                                     NSSecondCalendarUnit) fromDate:when];

    UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:date repeats:NO];


    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger ];

    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
             NSLog(@"alarm scheduled");
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"show"];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)close:(CDVInvokedUrlCommand*)command {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    NSArray *identifiers = @[[command.arguments objectAtIndex:0]];
    [center removeDeliveredNotificationsWithIdentifiers:identifiers];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)requestPermission:(CDVInvokedUrlCommand*)command {
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"granted"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"denied"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)notificationClicked {
    NSLog(@"in plugin, local notification clicked");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"click"];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

@end
