//
//  SubstratePlugin.m
//  macSubstrate
//
//  Created by GoKu on 28/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstratePlugin.h"
#import "SubstrateConstants.h"
#import <Security/Security.h>

@implementation SubstratePlugin

+ (SubstratePlugin *)getSubstratePluginWithPath:(NSString *)pluginPath
{
    if (pluginPath.length <= 0) {
        return nil;
    }
    
    if (![[SubstratePlugin getValidPluginFileTypes] containsObject:pluginPath.pathExtension]) {
        return nil;
    }
    
    NSBundle *pluginBundle = [NSBundle bundleWithPath:pluginPath];
    if (!pluginBundle) {
        return nil;
    }
    
    NSString *pluginFileName = pluginPath.lastPathComponent;
    NSString *pluginID = pluginBundle.bundleIdentifier;
    NSString *pluginVersion = [pluginBundle.infoDictionary valueForKey:@"CFBundleShortVersionString"];
    NSString *targetAppBundleID = [pluginBundle.infoDictionary valueForKeyPath:kSubstratePluginInfoKeyPathTargetAppBundleID];
    NSString *pluginAuthorName = [pluginBundle.infoDictionary valueForKeyPath:kSubstratePluginInfoKeyPathPluginAuthorName];
    NSString *pluginAuthorEmail = [pluginBundle.infoDictionary valueForKeyPath:kSubstratePluginInfoKeyPathPluginAuthorEmail];
    
    if ((pluginFileName.length > 0) &&
        (pluginID.length > 0) &&
        (pluginVersion.length > 0) &&
        (targetAppBundleID.length > 0)) {
        
        SubstratePlugin *plugin = [[SubstratePlugin alloc] init];
        plugin.pluginFileName = pluginFileName;
        plugin.pluginID = pluginID;
        plugin.pluginVersion = pluginVersion;
        plugin.targetAppBundleID = targetAppBundleID;
        plugin.pluginAuthorName = pluginAuthorName;
        plugin.pluginAuthorEmail = pluginAuthorEmail;
        
        return plugin;
        
    } else {
        return nil;
    }
}

+ (NSArray *)getValidPluginFileTypes
{
    return @[@"bundle", @"framework"];
}

+ (BOOL)verifyCodeSignatureWithPath:(NSString *)filePath
{
    if (filePath.length <= 0) {
        return NO;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    if (!fileURL) {
        return NO;
    }
    
    SecStaticCodeRef codeRef = NULL;
    OSStatus ret = SecStaticCodeCreateWithPath((__bridge CFURLRef)fileURL, kSecCSDefaultFlags, &codeRef);
    if ((ret != 0) || !codeRef) {
        return NO;
    }
    
    ret = SecStaticCodeCheckValidity(codeRef, kSecCSDefaultFlags, NULL);
    CFRelease(codeRef);
    
    return (ret == 0);
}

@end
