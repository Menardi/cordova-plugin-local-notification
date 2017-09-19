
@import UserNotifications;

#import <Cordova/CDV.h>
#import "W3CLocalNotifications.h"

@implementation W3CLocalNotifications : CDVPlugin

@synthesize callbackId;

- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;

    if ([type isEqualToString:@"image"]) {
        ext = @"jpg";
    }

    if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }

    if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }

    return [@"." stringByAppendingString:ext];
}

- (void)loadAttachmentForUrlString:(NSString *)urlString withType:(NSString *)type
                 completionHandler:(void(^)(UNNotificationAttachment *))completionHandler  {

    __block UNNotificationAttachment *attachment = nil;
    NSURL *attachmentURL = [NSURL URLWithString:urlString];
    NSString *fileExt = [self fileExtensionForMediaType:type];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL
        completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
            if (error != nil) {
                NSLog(@"%@", error.localizedDescription);
            } else {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
                [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];

                NSError *attachmentError = nil;
                attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
                if (attachmentError) {
                    NSLog(@"%@", attachmentError.localizedDescription);
                }
            }
            completionHandler(attachment);
        }] resume];
}

- (void)show:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = [command.arguments objectAtIndex:0];
    content.body = [command.arguments objectAtIndex:3];
    content.sound = [UNNotificationSound defaultSound];
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
    NSLog(@"loading icon image: %@",imageUrl);

    // load the attachment
    [self loadAttachmentForUrlString:imageUrl
        withType:@"jpg"
        completionHandler:^(UNNotificationAttachment *attachment) {
            if (attachment) {
                NSLog(@"loading icon image done adding to notification: %@",imageUrl);
                content.attachments = [NSArray arrayWithObject:attachment];
            }

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
    ];
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
