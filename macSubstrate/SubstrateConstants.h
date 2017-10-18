//
//  SubstrateConstants.h
//  macSubstrate
//
//  Created by GoKu on 28/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#ifndef SubstrateConstants_h
#define SubstrateConstants_h

#import <Foundation/Foundation.h>

#define NotifySuccessAndReturn      completeBlock(YES); return;
#define NotifyFailureAndReturn      completeBlock(NO); return;

FOUNDATION_EXPORT NSString *const   kSubstrateInstallerBundleID;
FOUNDATION_EXPORT NSString *const   kSubstrateHelperBundleID;

FOUNDATION_EXPORT NSString *const   kSubstrateFrameworkDirPath;
FOUNDATION_EXPORT NSString *const   kSubstrateFrameworkName;

FOUNDATION_EXPORT NSString *const   kSubstratePluginsInstallDirName;
FOUNDATION_EXPORT NSString *const   kSubstratePluginInfoKeyPathTargetAppBundleID;
FOUNDATION_EXPORT NSString *const   kSubstratePluginInfoKeyPathPluginAuthorName;
FOUNDATION_EXPORT NSString *const   kSubstratePluginInfoKeyPathPluginAuthorEmail;

@protocol SubstrateInstallerProtocol
@required
- (void)installSubstrateFramework:(NSString *)frameworkPath
                    completeBlock:(void(^)(BOOL success))completeBlock;
@end

@protocol SubstrateHelperProtocol
@required
- (void)installPlugin:(NSString *)pluginPath
            targetPID:(pid_t)pid
        completeBlock:(void(^)(BOOL success))completeBlock;
- (void)uninstallPlugin:(NSString *)pluginPath
          completeBlock:(void(^)(BOOL success))completeBlock;
- (void)loadPluginsForTargetApp:(NSString *)bundleID
                      targetPID:(pid_t)pid
                  completeBlock:(void(^)(BOOL success))completeBlock;
- (void)loadPluginsForTargetApps:(NSArray *)bundleIDList
                      targetPIDs:(NSArray *)pidList
                   completeBlock:(void(^)(BOOL success))completeBlock;
@end

#endif /* SubstrateConstants_h */
