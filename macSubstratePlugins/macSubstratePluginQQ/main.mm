//
//  main.mm
//  macSubstratePluginQQ
//
//  Created by GoKu on 19/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CaptainHook.h"
#import "SubstratePluginQQ.h"

CHDeclareClass(QQMessageRevokeEngine)

CHMethod(2, void, QQMessageRevokeEngine, handleRecallNotify, struct RecallModel *, arg1, isOnline, BOOL, arg2)
{
    [[SubstratePluginQQ sharedPlugin] handleRecallNotify:arg1 with:self];
}

__attribute__((constructor))
void macSubstratePluginQQEntry()
{
    NSLog(@"%s: hello %@ (%d), I am in :)", __FUNCTION__, [[NSBundle mainBundle] bundleIdentifier], getpid());
    
    CHLoadLateClass(QQMessageRevokeEngine);
    CHClassHook(2, QQMessageRevokeEngine, handleRecallNotify, isOnline);
}
