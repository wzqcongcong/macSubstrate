//
//  SubstratePluginWeChat.m
//  macSubstratePlugins
//
//  Created by GoKu on 11/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstratePluginWeChat.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <AppKit/AppKit.h>

@interface SubstratePluginWeChat () <NSUserNotificationCenterDelegate>

@property (nonatomic, weak) id<NSUserNotificationCenterDelegate> wechatDelegate;

@end

@implementation SubstratePluginWeChat

+ (instancetype)sharedPlugin
{
    static SubstratePluginWeChat *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SubstratePluginWeChat alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _wechatDelegate = [[NSUserNotificationCenter defaultUserNotificationCenter] delegate];
    }
    return self;
}

- (void)parseMessage:(MessageData *)message
{
    if (!message) {
        return;
    }
    
    if (message.messageType != 49) {
        return;
    }
    if ([message.msgContent rangeOfString:@"wxapp.tenpay.com"].location == NSNotFound) {
        return;
    }
    if (![message isChatRoomMessage]) {
        return;
    }
    if ([message isSendFromSelf]) {
        return;
    }
    
    NSString *notifyTitle = @"红包";
    WCContactData *contact = [objc_getClass("WCContactData") GetContactWithUserName:[message getChatNameForCurMsg]];
    if (contact) {
        notifyTitle = [NSString stringWithFormat:@"%@: %@", notifyTitle, [contact getGroupDisplayName]];
    }
    NSString *notifyInfo = [self matchStringWithPattern:@"<title><!\\[CDATA\\[(.*?)\\]\\]><\\/title>" inString:message.msgContent];
    
    [self notifyTitle:notifyTitle notifyInfo:notifyInfo notifyType:@"hongbao"];
}

- (void)onRevokeMsg:(NSString *)revokeMsg
    selfRevokeBlock:(void(^)(void))selfRevokeBlock
{
    if (!revokeMsg) {
        return;
    }
    
    NSString *newmsgid = [self matchStringWithPattern:@"<newmsgid>(.*?)<\\/newmsgid>" inString:revokeMsg];
    NSString *session = [self matchStringWithPattern:@"<session>(.*?)<\\/session>" inString:revokeMsg];
    NSString *replacemsg = [self matchStringWithPattern:@"<replacemsg><!\\[CDATA\\[(.*?)\\]\\]><\\/replacemsg>" inString:revokeMsg];
    
    NSString *notifyTitle = @"防撤";
    NSString *notifyInfo = replacemsg;
    
    MessageService *messageService = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("MessageService") class]];
    MessageData *message = [messageService GetMsgData:session svrId:newmsgid.longLongValue];
    if (message) {
        if ([message isSendFromSelf]) {
            selfRevokeBlock();
            return;
        }
        
        MessageData *localMsg = [[objc_getClass("MessageData") alloc] initWithMsgType:0x2710];
        localMsg.fromUsrName = message.fromUsrName;
        localMsg.toUsrName = message.toUsrName;
        localMsg.msgContent = (replacemsg.length > 0) ? [@"🈲 " stringByAppendingString:replacemsg] : @"🈲";
        localMsg.msgStatus = 0x4;
        localMsg.msgCreateTime = message.msgCreateTime;
        [messageService AddRevokePromptMsg:session msgData:localMsg];
        
        WCContactData *contact = [objc_getClass("WCContactData") GetContactWithUserName:[message getChatNameForCurMsg]];
        NSString *fromUserName = ([message isChatRoomMessage] ? [contact getGroupDisplayName] : [contact getContactDisplayName]);
        notifyTitle = [NSString stringWithFormat:@"%@: %@", notifyTitle, fromUserName];
    }
    
    [self notifyTitle:notifyTitle notifyInfo:notifyInfo notifyType:@"revoke"];
}

- (NSString *)matchStringWithPattern:(NSString *)pattern inString:(NSString *)inString
{
    if (!pattern || !inString) {
        return nil;
    }
    
    NSString *matchedString = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
    NSTextCheckingResult *result = [regex matchesInString:inString options:0 range:NSMakeRange(0, inString.length)].firstObject;
    if (result.numberOfRanges >= 2) {
        matchedString = [inString substringWithRange:[result rangeAtIndex:1]];
    }
    
    return matchedString;
}

- (void)notifyTitle:(NSString *)notifyTitle notifyInfo:(NSString *)notifyInfo notifyType:(NSString *)notifyType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = notifyTitle;
        notification.informativeText = notifyInfo;
        notification.hasActionButton = YES;
        notification.soundName = NSUserNotificationDefaultSoundName;
        notification.userInfo = @{NSStringFromClass([SubstratePluginWeChat class]): (notifyType ?: @"")};
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    });
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    if ([notification.userInfo valueForKey:NSStringFromClass([SubstratePluginWeChat class])]) {
        return YES;
        
    } else {
        if ([self.wechatDelegate respondsToSelector:@selector(userNotificationCenter:shouldPresentNotification:)]) {
            return [self.wechatDelegate userNotificationCenter:center shouldPresentNotification:notification];
        } else {
            return NO;
        }
    }
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    if ([self.wechatDelegate respondsToSelector:@selector(userNotificationCenter:didDeliverNotification:)]) {
        [self.wechatDelegate userNotificationCenter:center didDeliverNotification:notification];
    }
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    if ([self.wechatDelegate respondsToSelector:@selector(userNotificationCenter:didActivateNotification:)]) {
        [self.wechatDelegate userNotificationCenter:center didActivateNotification:notification];
    }
}

@end
