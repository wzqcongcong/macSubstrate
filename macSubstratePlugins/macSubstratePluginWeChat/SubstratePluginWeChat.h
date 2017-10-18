//
//  SubstratePluginWeChat.h
//  macSubstratePlugins
//
//  Created by GoKu on 11/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeChatHeader.h"

@interface SubstratePluginWeChat : NSObject

+ (instancetype)sharedPlugin;

- (void)parseMessage:(MessageData *)message;
- (void)onRevokeMsg:(NSString *)revokeMsg
    selfRevokeBlock:(void(^)(void))selfRevokeBlock;

@end
