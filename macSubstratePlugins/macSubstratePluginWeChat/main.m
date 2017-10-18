//
//  main.m
//  macSubstratePluginWeChat
//
//  Created by GoKu on 29/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CaptainHook.h"
#import "SubstratePluginWeChat.h"

CHDeclareClass(MessageService)

CHMethod(2, void, MessageService, notifyAddMsgOnMainThread, id, arg1, msgData, id, arg2)
{
    CHSuper(2, MessageService, notifyAddMsgOnMainThread, arg1, msgData, arg2);
    [[SubstratePluginWeChat sharedPlugin] parseMessage:(MessageData *)arg2];
}

CHMethod(1, void, MessageService, onRevokeMsg, id, arg1)
{
    [[SubstratePluginWeChat sharedPlugin] onRevokeMsg:(NSString *)arg1
                                      selfRevokeBlock:^{
                                          CHSuper(1, MessageService, onRevokeMsg, arg1);
                                      }];
}

__attribute__((constructor))
void macSubstratePluginWeChatEntry()
{
    NSLog(@"%s: hello %@ (%d), I am in :)", __FUNCTION__, [[NSBundle mainBundle] bundleIdentifier], getpid());
    
    CHLoadLateClass(MessageService);
    CHClassHook(2, MessageService, notifyAddMsgOnMainThread, msgData);
    CHClassHook(1, MessageService, onRevokeMsg);
}
