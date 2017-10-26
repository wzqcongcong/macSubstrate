//
//  SubstratePluginQQ.h
//  macSubstratePluginQQ
//
//  Created by GoKu on 20/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QQHeader.h"

@interface SubstratePluginQQ : NSObject

+ (instancetype)sharedPlugin;

- (void)handleRecallNotify:(struct RecallModel *)recallModel
                      with:(QQMessageRevokeEngine *)revokeEngine;

@end
