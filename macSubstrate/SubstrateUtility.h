//
//  SubstrateUtility.h
//  macSubstrate
//
//  Created by GoKu on 28/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SubstrateUtility : NSObject

+ (NSString *)getInstalledHelperVersion;
+ (NSString *)getAppHelperVersion;
+ (void)saveInstalledHelperVersion;
+ (NSString *)getInstalledFrameworkVersion;
+ (NSString *)getAppFrameworkVersion;
+ (NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB;

+ (BOOL)setupLoginItem;
+ (BOOL)loginItemEnabled;
+ (void)setLoginItemEnabled:(BOOL)enabled;

+ (NSString *)getAppNameFromBundleID:(NSString *)bundleID;
+ (NSImage *)getAppIconFromBundleID:(NSString *)bundleID;

@end
