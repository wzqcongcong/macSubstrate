//
//  SubstratePlugin.h
//  macSubstrate
//
//  Created by GoKu on 28/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 macSubstratePlugin
     TargetAppBundleID: the target app's CFBundleIdentifier, this tells macSubstrate which app to inject.
     Description: brief description of the plugin.
     AuthorName: author name of the plugin.
     AuthorEmail: author email of the plugin.
 */

@interface SubstratePlugin : NSObject

@property (nonatomic, strong) NSString *pluginFileName;
@property (nonatomic, strong) NSString *pluginID;
@property (nonatomic, strong) NSString *pluginVersion;
@property (nonatomic, strong) NSString *targetAppBundleID;
@property (nonatomic, strong) NSString *pluginDescription;
@property (nonatomic, strong) NSString *pluginAuthorName;
@property (nonatomic, strong) NSString *pluginAuthorEmail;

+ (SubstratePlugin *)getSubstratePluginWithPath:(NSString *)pluginPath;
+ (NSArray *)getValidPluginFileTypes;

+ (BOOL)verifyCodeSignatureWithPath:(NSString *)filePath;

@end
