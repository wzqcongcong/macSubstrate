//
//  SubstrateUtility.m
//  macSubstrate
//
//  Created by GoKu on 28/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstrateUtility.h"
#import "SubstrateConstants.h"
#import <ServiceManagement/ServiceManagement.h>

NSString *const kConfigInstalledHelperVersion   = @"kConfigInstalledHelperVersion";
NSString *const kHelperInfoPlistName            = @"macSubstrateHelper-Info.plist";

NSString *const kLoginItemBundleID              = @"com.gokustudio.macSubstrateLogin";
NSString *const kLoginItemEnabled               = @"LoginItemEnabled";
BOOL const kLoginItemEnabledDefaultValue        = NO;

@implementation SubstrateUtility

+ (NSString *)getInstalledHelperVersion
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kConfigInstalledHelperVersion];
}

+ (NSString *)getAppHelperVersion
{
    NSString *helperInfoPlistPath = [[NSBundle mainBundle] pathForResource:kHelperInfoPlistName ofType:nil];
    NSDictionary *helperInfoPlist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:helperInfoPlistPath]
                                                                              options:NSPropertyListImmutable
                                                                               format:nil
                                                                                error:NULL];
    return [helperInfoPlist valueForKey:@"CFBundleShortVersionString"];
}

+ (void)saveInstalledHelperVersion
{
    [[NSUserDefaults standardUserDefaults] setValue:[SubstrateUtility getAppHelperVersion]
                                             forKey:kConfigInstalledHelperVersion];
}

+ (NSString *)getInstalledFrameworkVersion
{
    NSString *frameworkPath = [kSubstrateFrameworkDirPath stringByAppendingPathComponent:kSubstrateFrameworkName];
    NSBundle *framework = [NSBundle bundleWithPath:frameworkPath];
    if (!framework) {
        return nil;
    }
    
    return [[framework infoDictionary] valueForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppFrameworkVersion
{
    NSString *frameworkPath = [[NSBundle mainBundle] pathForResource:kSubstrateFrameworkName ofType:nil];
    NSBundle *framework = [NSBundle bundleWithPath:frameworkPath];
    if (!framework) {
        return nil;
    }
    
    return [[framework infoDictionary] valueForKey:@"CFBundleShortVersionString"];
}

+ (NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB
{
    if ((versionA.length <= 0) && (versionB.length <= 0)) {
        return NSOrderedSame;
    } else if (versionA.length <= 0) {
        return NSOrderedAscending;
    } else if (versionB.length <= 0) {
        return NSOrderedDescending;
    }
    
    NSArray *partsA = [versionA componentsSeparatedByString:@"."];
    NSArray *partsB = [versionB componentsSeparatedByString:@"."];

    NSUInteger sameCount = MIN(partsA.count, partsB.count);
    
    for (NSUInteger i = 0; i < sameCount; ++i) {
        NSString *partA = [partsA objectAtIndex:i];
        NSString *partB = [partsB objectAtIndex:i];
        if (partA.longLongValue < partB.longLongValue) {
            return NSOrderedAscending;
        } else if (partA.longLongValue > partB.longLongValue) {
            return NSOrderedDescending;
        }
    }
    
    if (partsA.count < partsB.count) {
        return NSOrderedAscending;
    } else if (partsA.count > partsB.count) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

+ (BOOL)setupLoginItem
{
    BOOL enabled = [SubstrateUtility loginItemEnabled];
    BOOL ret = SMLoginItemSetEnabled((__bridge CFStringRef)kLoginItemBundleID, enabled);
    NSLog(@"login item enabled: %d, setup ret: %d", enabled, ret);
    return ret;
}

+ (BOOL)loginItemEnabled
{
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginItemEnabled];
    return ((value != nil) ? [value boolValue] : kLoginItemEnabledDefaultValue);
}

+ (void)setLoginItemEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kLoginItemEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getAppNameFromBundleID:(NSString *)bundleID
{
    NSString *appPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleID];
    if (!appPath) {
        return bundleID;
    }
    
    NSBundle *app = [NSBundle bundleWithPath:appPath];
    if (!app) {
        return bundleID;
    }
    
    NSString *appName = [app.localizedInfoDictionary valueForKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [app.localizedInfoDictionary valueForKey:@"CFBundleName"];
    }
    if (!appName) {
        appName = [app.infoDictionary valueForKey:@"CFBundleDisplayName"];
    }
    if (!appName) {
        appName = [app.infoDictionary valueForKey:@"CFBundleName"];
    }
    return appName;
}

+ (NSImage *)getAppIconFromBundleID:(NSString *)bundleID
{
    NSString *appPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleID];
    if (!appPath) {
        return [NSImage imageNamed:NSImageNameStatusUnavailable];
    }
    
    NSImage *appIcon = [[NSWorkspace sharedWorkspace] iconForFile:appPath];
    return (appIcon ?: [NSImage imageNamed:NSImageNameStatusAvailable]);
}

@end
