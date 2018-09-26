
@import UserNotifications;

#import <Cordova/CDV.h>
#import "W3CLocalNotifications.h"

@implementation W3CLocalNotifications : CDVPlugin

@synthesize callbackId;

- (UNNotificationSound*)getSound:(NSString*)path {
    if([path hasPrefix:@"file://"]) {
        NSString* localPath = [path stringByReplacingOccurrencesOfString:@"file://" withString:@"/www/"];

        return [UNNotificationSound soundNamed:localPath];
    }

    return [UNNotificationSound defaultSound];
}

- (void)realshow:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];

    content.title = [command.arguments objectAtIndex:1];
    content.body = [command.arguments objectAtIndex:2];
    // content.badge = [NSNumber numberWithInt:1];

    NSString *identifier = [command.arguments objectAtIndex:0];
    NSString *imageUrl = [command.arguments objectAtIndex:4];
    NSString *soundUrl = [command.arguments objectAtIndex:5];

    content.userInfo = @{@"deep_link_action": [command.arguments objectAtIndex:6], @"imageUrl": imageUrl, @"soundUrl": soundUrl};

    double ms = [[command.arguments objectAtIndex:3] doubleValue];
    NSDate *when = [NSDate dateWithTimeIntervalSince1970:ms / 1000.0];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *date = [calendar components:(NSCalendarUnitYear  |
                                                   NSCalendarUnitMonth |
                                                   NSCalendarUnitDay   |
                                                   NSCalendarUnitHour  |
                                                   NSCalendarUnitMinute |
                                                   NSCalendarUnitSecond) fromDate:when];

    UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:date repeats:NO];

    //[content setValue:@YES forKey:@"shouldAlwaysAlertWhileAppIsForeground"];

    NSLog(@"Loading notification sound: %@",soundUrl);
    content.sound = [self getSound:soundUrl];

    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger ];

    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            NSLog(@"Notification scheduled (tag: %@)", identifier);
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"show"];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)show:(CDVInvokedUrlCommand*)command {
    [self performSelectorInBackground:@selector(realshow:) withObject:command];
}

- (void)close:(CDVInvokedUrlCommand*)command {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    NSArray *identifiers = @[[command.arguments objectAtIndex:0]];
    [center removePendingNotificationRequestsWithIdentifiers:identifiers];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)requestPermission:(CDVInvokedUrlCommand*)command {
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge;
    UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"granted"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"denied"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)hasPermission:(CDVInvokedUrlCommand*)command {
    UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;

    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings* settings) {
        BOOL granted = (settings.authorizationStatus == UNAuthorizationStatusAuthorized) && (settings.notificationCenterSetting == UNNotificationSettingEnabled);

        if (granted) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"granted"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"denied"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)openPermissionScreen:(CDVInvokedUrlCommand*)command {
   NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)setBadge:(CDVInvokedUrlCommand*)command {
    int count = [[command.arguments objectAtIndex:0] intValue];
    NSLog(@"Setting badge to %d", count);
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

- (void)notificationClicked {
    NSLog(@"in plugin, local notification clicked");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"click"];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (void)deviceready {
    // Not needed on iOS
}

@end
