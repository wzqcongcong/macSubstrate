//
//  SubstrateEngineManager.h
//  macSubstrate
//
//  Created by GoKu on 28/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SubstrateEngineManager : NSObject

+ (instancetype)sharedManager;

- (void)setupEngineWithCompleteBlock:(void(^)(BOOL engineReady))completeBlock;

@end
