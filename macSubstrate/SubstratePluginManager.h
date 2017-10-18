//
//  SubstratePluginManager.h
//  macSubstrate
//
//  Created by GoKu on 28/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SubstratePluginManager : NSObject

+ (instancetype)sharedManager;

+ (NSArray *)getInstalledPluginList;

- (void)installPlugin:(NSString *)pluginPath
        completeBlock:(void(^)(BOOL success))completeBlock;
- (void)uninstallPlugin:(NSString *)pluginPath
          completeBlock:(void(^)(BOOL success))completeBlock;

- (void)tryToLoadPluginsForApp:(NSRunningApplication *)app
                 completeBlock:(void(^)(BOOL success))completeBlock;
- (void)tryToLoadPluginsForAppList:(NSArray *)appList
                     completeBlock:(void(^)(BOOL success))completeBlock;

@end
