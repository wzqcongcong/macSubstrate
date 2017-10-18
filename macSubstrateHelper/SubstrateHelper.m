//
//  SubstrateHelper.m
//  macSubstrateHelper
//
//  Created by GoKu on 28/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstrateHelper.h"
#import "SubstratePlugin.h"
#import "mach_inject_bundle.h"

@implementation SubstrateHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _listener = [[NSXPCListener alloc] initWithMachServiceName:kSubstrateHelperBundleID];
        [_listener setDelegate:self];
    }
    return self;
}

- (void)run
{
    NSLog(@"%s", __FUNCTION__);

    [self.listener resume];
    
    [[NSRunLoop currentRunLoop] run];
}

- (void)installPlugin:(NSString *)pluginPath
            targetPID:(pid_t)pid
        completeBlock:(void(^)(BOOL success))completeBlock
{
    NSLog(@"install plugin: %@, pid: %d", pluginPath, pid);
    
    SubstratePlugin *plugin = [SubstratePlugin getSubstratePluginWithPath:pluginPath];
    if (!plugin) {
        NotifyFailureAndReturn
    }
    NSLog(@"install plugin for app: %@", plugin.targetAppBundleID);
    
    BOOL ret = YES;
    
    NSString *installDir = [kSubstratePluginsInstallDirName stringByAppendingPathComponent:plugin.targetAppBundleID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:installDir]) {
        ret = [[NSFileManager defaultManager] createDirectoryAtPath:installDir
                                        withIntermediateDirectories:YES
                                                         attributes:nil
                                                              error:NULL];
    }
    if (!ret) {
        NotifyFailureAndReturn
    }
    
    NSString *installPath = [installDir stringByAppendingPathComponent:plugin.pluginFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:installPath]) {
        SubstratePlugin *existedPlugin = [SubstratePlugin getSubstratePluginWithPath:installPath];
        if (existedPlugin && ![existedPlugin.pluginID isEqualToString:plugin.pluginID]) {
            NSString *name = plugin.pluginFileName.stringByDeletingPathExtension;
            NSString *extension = plugin.pluginFileName.pathExtension;
            NSString *newFileName = [NSString stringWithFormat:@"%@_%f.%@", name, [[NSDate date] timeIntervalSinceReferenceDate], extension];
            installPath = [installDir stringByAppendingPathComponent:newFileName];
        } else {
            ret = [[NSFileManager defaultManager] removeItemAtPath:installPath error:NULL];
        }
    }
    if (ret) {
        ret = [[NSFileManager defaultManager] copyItemAtPath:pluginPath toPath:installPath error:NULL];
    }
    if (!ret) {
        NotifyFailureAndReturn
    }
    
    if (pid <= 0) {
        NSLog(@"app %@ is not running, no need to inject now.", plugin.targetAppBundleID);
        NotifySuccessAndReturn
    } else {
        mach_error_t error = [self injectApp:pid withPlugin:installPath];
        completeBlock(error == err_none);
    }
}

- (void)uninstallPlugin:(NSString *)pluginPath
          completeBlock:(void(^)(BOOL success))completeBlock
{
    NSLog(@"uninstall plugin: %@", pluginPath);
    
    SubstratePlugin *plugin = [SubstratePlugin getSubstratePluginWithPath:pluginPath];
    if (!plugin) {
        NotifyFailureAndReturn
    }
    NSLog(@"uninstall plugin for app: %@", plugin.targetAppBundleID);
    
    BOOL ret = [[NSFileManager defaultManager] removeItemAtPath:pluginPath error:NULL];
    completeBlock(ret);
}

- (void)loadPluginsForTargetApp:(NSString *)bundleID
                      targetPID:(pid_t)pid
                  completeBlock:(void(^)(BOOL success))completeBlock
{
    NSLog(@"load plugins for app: %@, pid: %d", bundleID, pid);
    
    if ((bundleID.length <= 0) || (pid <= 0)) {
        NotifyFailureAndReturn
    }
    
    NSString *targetAppPluginsDir = [kSubstratePluginsInstallDirName stringByAppendingPathComponent:bundleID];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetAppPluginsDir error:NULL];
    for (NSString *item in contents) {
        NSString *pluginPath = [targetAppPluginsDir stringByAppendingPathComponent:item];
        if ([SubstratePlugin getSubstratePluginWithPath:pluginPath]) {
            [self injectApp:pid withPlugin:pluginPath];
        }
    }
    
    NotifySuccessAndReturn
}

- (void)loadPluginsForTargetApps:(NSArray *)bundleIDList
                      targetPIDs:(NSArray *)pidList
                   completeBlock:(void(^)(BOOL success))completeBlock
{
    if ((bundleIDList.count != pidList.count) || (bundleIDList.count <= 0)) {
        NotifyFailureAndReturn
    }
    NSLog(@"load plugins for %lu apps", (unsigned long)bundleIDList.count);
    
    for (int i = 0; i < bundleIDList.count; ++i) {
        NSString *bundleID = bundleIDList[i];
        pid_t pid = [pidList[i] intValue];
        
        if ((bundleID.length <= 0) || (pid <= 0)) {
            continue;
        }
        
        NSString *targetAppPluginsDir = [kSubstratePluginsInstallDirName stringByAppendingPathComponent:bundleID];
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetAppPluginsDir error:NULL];
        for (NSString *item in contents) {
            NSString *pluginPath = [targetAppPluginsDir stringByAppendingPathComponent:item];
            if ([SubstratePlugin getSubstratePluginWithPath:pluginPath]) {
                [self injectApp:pid withPlugin:pluginPath];
            }
        }
    }
    
    NotifySuccessAndReturn
}

- (mach_error_t)injectApp:(pid_t)pid withPlugin:(NSString *)pluginPath
{
    NSLog(@"inject pid: %d, plugin: %@", pid, pluginPath);
    
    if ((pid <= 0) || (pluginPath.length <= 0)) {
        return err_local;
    }
    
    mach_error_t error = mach_inject_bundle_pid(pluginPath.fileSystemRepresentation, pid);
    NSLog(@"injection error: %d", error);
    return error;
}

#pragma mark - NSXPCListenerDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
    assert(listener == self.listener);
    assert(newConnection);
    
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SubstrateHelperProtocol)];
    newConnection.exportedObject = self;
    [newConnection resume];
    
    return YES;
}

@end
