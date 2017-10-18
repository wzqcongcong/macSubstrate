//
//  SubstrateEngineManager.m
//  macSubstrate
//
//  Created by GoKu on 28/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstrateEngineManager.h"
#import "SubstrateEngineProxy.h"
#import "SubstratePluginManager.h"
#import "SubstrateUtility.h"
#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>

@interface SubstrateEngineManager ()
{
    AuthorizationRef _authRef;
}
@end

@implementation SubstrateEngineManager

+ (instancetype)sharedManager
{
    static SubstrateEngineManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SubstrateEngineManager alloc] init];
    });
    return sharedInstance;
}

- (void)setupEngineWithCompleteBlock:(void(^)(BOOL engineReady))completeBlock
{
    NSLog(@"%s", __FUNCTION__);
    
    if ([self needUpdateSubstrateEngine]) {
        [self updateSubstrateEngineWithCompleteBlock:^(BOOL success) {
            [self setupEngine:success];
            completeBlock(success);
        }];
    } else {
        [self setupEngine:YES];
        completeBlock(YES);
    }
}

- (void)setupEngine:(BOOL)engineReady
{
    if (!engineReady) {
        return;
    }
    
    NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    [notificationCenter addObserverForName:NSWorkspaceDidLaunchApplicationNotification
                                    object:nil
                                     queue:nil
                                usingBlock:^(NSNotification * _Nonnull note) {
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        NSRunningApplication *app = [note.userInfo valueForKey:NSWorkspaceApplicationKey];
                                        [[SubstratePluginManager sharedManager] tryToLoadPluginsForApp:app
                                                                                         completeBlock:^(BOOL success) {
                                                                                             NSLog(@"try to load plugins for %@ ret: %d", app.bundleIdentifier, success);
                                                                                         }];
                                    });
                                }];
    
    NSArray *appList = [[NSWorkspace sharedWorkspace] runningApplications];
    [[SubstratePluginManager sharedManager] tryToLoadPluginsForAppList:appList
                                                         completeBlock:^(BOOL success) {
                                                             NSLog(@"try to load plugins for apps ret: %d", success);
                                                         }];
}

- (BOOL)needUpdateSubstrateEngine
{
    NSLog(@"engine status: %@, %@, %@, %@",
          [SubstrateUtility getInstalledHelperVersion],
          [SubstrateUtility getAppHelperVersion],
          [SubstrateUtility getInstalledFrameworkVersion],
          [SubstrateUtility getAppFrameworkVersion]);
    return ([self needUpdateFramework] || [self needUpdateHelper]);
}

- (BOOL)needUpdateFramework
{
    return (NSOrderedAscending == [SubstrateUtility compareVersion:[SubstrateUtility getInstalledFrameworkVersion]
                                                         toVersion:[SubstrateUtility getAppFrameworkVersion]]);
}

- (BOOL)needUpdateHelper
{
    return (NSOrderedAscending == [SubstrateUtility compareVersion:[SubstrateUtility getInstalledHelperVersion]
                                                         toVersion:[SubstrateUtility getAppHelperVersion]]);
}

- (void)updateSubstrateEngineWithCompleteBlock:(void(^)(BOOL success))completeBlock
{
    NSLog(@"%s", __FUNCTION__);
    
    [self updateFrameworkWithCompleteBlock:^(BOOL success) {
        if (success) {
            [self updateHelperWithCompleteBlock:completeBlock];
        } else {
            NotifyFailureAndReturn
        }
    }];
}

- (void)updateFrameworkWithCompleteBlock:(void(^)(BOOL success))completeBlock
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self grantAuthorization]) {
        NotifyFailureAndReturn
    }
    
    CFErrorRef errorRef = NULL;
    Boolean ret = SMJobBless(kSMDomainSystemLaunchd, (__bridge CFStringRef)kSubstrateInstallerBundleID, _authRef, &errorRef);
    if (!ret) {
        NSLog(@"job bless error: %@", (__bridge NSError *)errorRef);
        NotifyFailureAndReturn
    }
    
    id<SubstrateInstallerProtocol> installer = [[SubstrateEngineProxy sharedProxy] getInstallerWithErrorHandler:^(NSError *error) {
        NSLog(@"xpc error: %@", error);
        NotifyFailureAndReturn
    }];
    [installer installSubstrateFramework:[[NSBundle mainBundle] pathForResource:kSubstrateFrameworkName ofType:nil]
                           completeBlock:completeBlock];
}

- (void)updateHelperWithCompleteBlock:(void(^)(BOOL success))completeBlock
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self grantAuthorization]) {
        NotifyFailureAndReturn
    }
    
    CFErrorRef errorRef = NULL;
    Boolean ret = SMJobBless(kSMDomainSystemLaunchd, (__bridge CFStringRef)kSubstrateHelperBundleID, _authRef, &errorRef);
    if (!ret) {
        NSLog(@"job bless error: %@", (__bridge NSError *)errorRef);
        NotifyFailureAndReturn
    }
    
    [SubstrateUtility saveInstalledHelperVersion];
    
    NotifySuccessAndReturn

    // to update the new privileged helper into PrivilegedHelperTools dir,
    // need to update the CFBundleVersion of privileged helper to a new version,
    // then Mac OS will deploy the new version of privileged helper.
}

- (BOOL)grantAuthorization
{
    if (_authRef) {
        return YES;
    }
    
    AuthorizationItem authItem[1];
    authItem[0] = (AuthorizationItem){kSMRightBlessPrivilegedHelper, 0, NULL, 0};
    AuthorizationRights authRights = {1, authItem};
    AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights;
    
    OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &_authRef);
    NSLog(@"authorization status: %d", status);
    
    return (status == errAuthorizationSuccess);
}

@end
