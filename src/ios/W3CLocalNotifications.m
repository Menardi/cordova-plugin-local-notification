
@import UserNotifications;

#import <Cordova/CDV.h>
#import "W3CLocalNotifications.h"

@implementation W3CLocalNotifications : CDVPlugin

@synthesize callbackId;

- (UNNotificationAttachment*)loadAttachment:(NSString *)urlString {
    NSURL *attachmentURL = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:attachmentURL];
    if (data) {
        NSURL *localURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[attachmentURL lastPathComponent]]];
        NSLog(@"writing notification attachment to tmp: %@",localURL);
        if([data writeToURL:localURL atomically:NO]) {
            NSError *attachmentError = nil;
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
            if (attachmentError) {
                NSLog(@"error adding attachment: %@", attachmentError.localizedDescription);
            } else {
                return attachment;
            }
        }
    }
    return NULL;
}

- (UNNotificationSound*)loadSound:(NSString *)urlString {
    NSURL *attachmentURL = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:attachmentURL];
    if (data) {
        NSString *soundsDir = [NSHomeDirectory() stringByAppendingString:@"/Library/Sounds/"];
        NSFileManager *fileManager= [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:soundsDir isDirectory:NULL]) {
            if(![fileManager createDirectoryAtPath:soundsDir withIntermediateDirectories:YES attributes:nil error:NULL]) {
                NSLog(@"Cannot create sounds folder: %@", soundsDir);
                return [UNNotificationSound defaultSound];
            }
        }
        NSURL *localURL = [NSURL fileURLWithPath:[soundsDir stringByAppendingPathComponent:[attachmentURL lastPathComponent]]];
        NSLog(@"Sound local url: %@", localURL);
        if([data writeToURL:localURL atomically:NO]) {
            return [UNNotificationSound soundNamed:[attachmentURL lastPathComponent]];
        }
    }
    return [UNNotificationSound defaultSound];;
}

- (void)realshow:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = [command.arguments objectAtIndex:0];
    content.body = [command.arguments objectAtIndex:3];
    content.badge = [NSNumber numberWithInt:1];
    content.userInfo = @{@"deep_link_action": [command.arguments objectAtIndex:8]};
    NSString *identifier = [command.arguments objectAtIndex:4];
    double ms = [[command.arguments objectAtIndex:7] doubleValue];
    NSDate *when = [NSDate dateWithTimeIntervalSince1970:ms / 1000.0];
    //NSISO8601DateFormatter *dateFormatter = [[NSISO8601DateFormatter alloc] init];
    //NSLog(@"Notification set at: %@",[dateFormatter stringFromDate:when]);
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *date = [calendar components:(NSCalendarUnitYear  |
                                                   NSCalendarUnitMonth |
                                                   NSCalendarUnitDay   |
                                                   NSCalendarUnitHour  |
                                                   NSCalendarUnitMinute |
                                                   NSCalendarUnitSecond) fromDate:when];
    UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:date repeats:NO];
    [content setValue:@YES forKey:@"shouldAlwaysAlertWhileAppIsForeground"];
    NSString *imageUrl = [command.arguments objectAtIndex:5];
    UNNotificationAttachment *imageAttachment = [self loadAttachment:imageUrl];
    if (imageAttachment) {
        NSLog(@"loading notification image: %@",imageUrl);
        content.attachments = @[imageAttachment];
    }
    NSString *soundUrl = [command.arguments objectAtIndex:6];
    NSLog(@"loading notification sound: %@",soundUrl);
    content.sound = [self loadSound:soundUrl];
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
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
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
- (void)settings:(CDVInvokedUrlCommand*)command {
    NSLog(@"in plugin, settings");

    if (&UIApplicationOpenSettingsURLString != NULL) {
       NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}
- (void)notificationClicked {
    NSLog(@"in plugin, local notification clicked");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"click"];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

@end
