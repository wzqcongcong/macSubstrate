//
//  SubstratePluginManager.m
//  macSubstrate
//
//  Created by GoKu on 28/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstratePluginManager.h"
#import "SubstratePlugin.h"
#import "SubstrateEngineProxy.h"
#import "SubstrateConstants.h"

#define LeaveGroupAndNotifySuccessAndReturn     dispatch_group_leave(group); completeBlock(YES); return;
#define LeaveGroupAndNotifyFailureAndReturn     dispatch_group_leave(group); completeBlock(NO); return;

@interface SubstratePluginManager ()
{
    dispatch_queue_t _workQueue;
}
@end

@implementation SubstratePluginManager

+ (instancetype)sharedManager
{
    static SubstratePluginManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SubstratePluginManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _workQueue = dispatch_queue_create("SubstratePluginManagerWorkQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (NSArray *)getInstalledPluginList
{
    NSMutableArray *list = [NSMutableArray array];
    
    NSArray *targetApps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kSubstratePluginsInstallDirName error:NULL];
    for (NSString *bundleID in targetApps) {
        NSString *targetAppPluginsDir = [kSubstratePluginsInstallDirName stringByAppendingPathComponent:bundleID];
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetAppPluginsDir error:NULL];
        for (NSString *item in contents) {
            NSString *pluginPath = [targetAppPluginsDir stringByAppendingPathComponent:item];
            SubstratePlugin *plugin = [SubstratePlugin getSubstratePluginWithPath:pluginPath];
            if (plugin) {
                [list addObject:plugin];
            }
        }
    }
    
    return list;
}

- (void)installPlugin:(NSString *)pluginPath
        completeBlock:(void(^)(BOOL success))completeBlock
{
    dispatch_async(_workQueue, ^{
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        
        NSLog(@"install plugin: %@", pluginPath);
        
        SubstratePlugin *plugin = [SubstratePlugin getSubstratePluginWithPath:pluginPath];
        if (!plugin) {
            LeaveGroupAndNotifyFailureAndReturn
        }
        NSLog(@"install plugin for app: %@", plugin.targetAppBundleID);
        
        pid_t pid = 0;
        NSRunningApplication *targetApp = [NSRunningApplication runningApplicationsWithBundleIdentifier:plugin.targetAppBundleID].firstObject;
        if (targetApp) {
            pid = targetApp.processIdentifier;
            NSLog(@"install plugin for pid: %d", pid);
        }
        
        id<SubstrateHelperProtocol> helper = [[SubstrateEngineProxy sharedProxy] getHelperWithErrorHandler:^(NSError *error) {
            NSLog(@"xpc error: %@", error);
            LeaveGroupAndNotifyFailureAndReturn
        }];
        [helper installPlugin:pluginPath targetPID:pid completeBlock:^(BOOL success) {
            dispatch_group_leave(group);
            completeBlock(success);
        }];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    });
}

- (void)uninstallPlugin:(NSString *)pluginPath
          completeBlock:(void(^)(BOOL success))completeBlock
{
    dispatch_async(_workQueue, ^{
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        
        NSLog(@"uninstall plugin: %@", pluginPath);
        
        SubstratePlugin *plugin = [SubstratePlugin getSubstratePluginWithPath:pluginPath];
        if (!plugin) {
            LeaveGroupAndNotifyFailureAndReturn
        }
        NSLog(@"uninstall plugin for app: %@", plugin.targetAppBundleID);
        
        id<SubstrateHelperProtocol> helper = [[SubstrateEngineProxy sharedProxy] getHelperWithErrorHandler:^(NSError *error) {
            NSLog(@"xpc error: %@", error);
            LeaveGroupAndNotifyFailureAndReturn
        }];
        [helper uninstallPlugin:pluginPath completeBlock:^(BOOL success) {
            dispatch_group_leave(group);
            completeBlock(success);
        }];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    });
}

- (void)tryToLoadPluginsForApp:(NSRunningApplication *)app
                 completeBlock:(void(^)(BOOL success))completeBlock
{
    dispatch_async(_workQueue, ^{
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        
        NSString *bundleID = app.bundleIdentifier;
        NSLog(@"try to load plugins for %@", bundleID);
        if (bundleID.length <= 0) {
            LeaveGroupAndNotifySuccessAndReturn
        }
        
        NSString *targetAppPluginsDir = [kSubstratePluginsInstallDirName stringByAppendingPathComponent:bundleID];
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetAppPluginsDir error:NULL];
        if (contents.count <= 0) {
            LeaveGroupAndNotifySuccessAndReturn
        }
        
        id<SubstrateHelperProtocol> helper = [[SubstrateEngineProxy sharedProxy] getHelperWithErrorHandler:^(NSError *error) {
            NSLog(@"xpc error: %@", error);
            LeaveGroupAndNotifyFailureAndReturn
        }];
        [helper loadPluginsForTargetApp:bundleID targetPID:app.processIdentifier completeBlock:^(BOOL success) {
            dispatch_group_leave(group);
            completeBlock(success);
        }];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    });
}

- (void)tryToLoadPluginsForAppList:(NSArray *)appList
                     completeBlock:(void(^)(BOOL success))completeBlock
{
    dispatch_async(_workQueue, ^{
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        
        NSMutableArray *bundleIDList = [NSMutableArray array];
        NSMutableArray *pidList = [NSMutableArray array];
        
        for (NSRunningApplication *app in appList) {
            NSString *bundleID = app.bundleIdentifier;
            if (bundleID.length > 0) {
                NSString *targetAppPluginsDir = [kSubstratePluginsInstallDirName stringByAppendingPathComponent:bundleID];
                NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetAppPluginsDir error:NULL];
                if (contents.count > 0) {
                    [bundleIDList addObject:bundleID];
                    [pidList addObject:@(app.processIdentifier)];
                }
            }
        }
        
        NSLog(@"try to load plugins for %lu apps", (unsigned long)bundleIDList.count);
        if (bundleIDList.count <= 0) {
            LeaveGroupAndNotifySuccessAndReturn
        }
        
        id<SubstrateHelperProtocol> helper = [[SubstrateEngineProxy sharedProxy] getHelperWithErrorHandler:^(NSError *error) {
            NSLog(@"xpc error: %@", error);
            LeaveGroupAndNotifyFailureAndReturn
        }];
        [helper loadPluginsForTargetApps:bundleIDList targetPIDs:pidList completeBlock:^(BOOL success) {
            dispatch_group_leave(group);
            completeBlock(success);
        }];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    });
}

@end
