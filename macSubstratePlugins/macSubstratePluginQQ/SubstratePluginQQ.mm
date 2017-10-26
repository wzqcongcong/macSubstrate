//
//  SubstratePluginQQ.m
//  macSubstratePluginQQ
//
//  Created by GoKu on 20/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstratePluginQQ.h"

@interface SubstratePluginQQ () <NSUserNotificationCenterDelegate>

@property (nonatomic, weak) id<NSUserNotificationCenterDelegate> qqDelegate;

@end

@implementation SubstratePluginQQ

+ (instancetype)sharedPlugin
{
    static SubstratePluginQQ *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SubstratePluginQQ alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _qqDelegate = [[NSUserNotificationCenter defaultUserNotificationCenter] delegate];
    }
    return self;
}

- (void)handleRecallNotify:(struct RecallModel *)recallModel
                      with:(QQMessageRevokeEngine *)revokeEngine
{
    NSString *notifyTitle = @"🈲";
    
    NSString *content = [[revokeEngine getProcessor] getRecallMessageContent:recallModel];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:NULL];
    
    if (json && [NSJSONSerialization isValidJSONObject:json]) {
        for (NSDictionary *item in json) {
            NSString *text = item[@"text"];
            NSString *notifyInfo = ((text.length > 0) ? text : @"消息撤回");
            [self notifyTitle:notifyTitle notifyInfo:notifyInfo notifyType:@"revoke"];
        }
        
    } else {
        NSString *notifyInfo = @"消息撤回";
        [self notifyTitle:notifyTitle notifyInfo:notifyInfo notifyType:@"revoke"];
    }
}

- (void)notifyTitle:(NSString *)notifyTitle notifyInfo:(NSString *)notifyInfo notifyType:(NSString *)notifyType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = notifyTitle;
        notification.informativeText = notifyInfo;
        notification.hasActionButton = YES;
        notification.soundName = NSUserNotificationDefaultSoundName;
        notification.userInfo = @{NSStringFromClass([SubstratePluginQQ class]): (notifyType ?: @"")};
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    });
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    if ([notification.userInfo valueForKey:NSStringFromClass([SubstratePluginQQ class])]) {
        return YES;
        
    } else {
        if ([self.qqDelegate respondsToSelector:@selector(userNotificationCenter:shouldPresentNotification:)]) {
            return [self.qqDelegate userNotificationCenter:center shouldPresentNotification:notification];
        } else {
            return NO;
        }
    }
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    if ([self.qqDelegate respondsToSelector:@selector(userNotificationCenter:didDeliverNotification:)]) {
        [self.qqDelegate userNotificationCenter:center didDeliverNotification:notification];
    }
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    if ([self.qqDelegate respondsToSelector:@selector(userNotificationCenter:didActivateNotification:)]) {
        [self.qqDelegate userNotificationCenter:center didActivateNotification:notification];
    }
}

@end
