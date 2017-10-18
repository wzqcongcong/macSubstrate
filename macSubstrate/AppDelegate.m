//
//  AppDelegate.m
//  macSubstrate
//
//  Created by GoKu on 27/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "AppDelegate.h"
#import "SubstrateEngineManager.h"
#import "SubstratePluginManager.h"
#import "SubstrateUtility.h"
#import "SubstrateStatusBarController.h"
#import "SubstrateWindowController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self redirectLog];
    
    [[SubstrateEngineManager sharedManager] setupEngineWithCompleteBlock:^(BOOL engineReady) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (engineReady) {
                [self onSubstrateEngineReady];
            } else {
                [self onSubstrateEngineFailed];
            }
        });
    }];
}

- (void)onSubstrateEngineReady
{
    NSLog(@"%s", __FUNCTION__);
    
    [SubstrateStatusBarController sharedController];
    
    [SubstrateUtility setupLoginItem];
}

- (void)onSubstrateEngineFailed
{
    NSLog(@"%s", __FUNCTION__);
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleCritical;
    alert.messageText = [NSString stringWithFormat:@"Unable to install all files needed by %@", [[NSRunningApplication currentApplication] localizedName]];
    alert.informativeText = [NSString stringWithFormat:@"Please relaunch %@ and allow it to install.", [[NSRunningApplication currentApplication] localizedName]];
    [alert runModal];
    
    [NSApp terminate:self];
}

- (void)redirectLog
{
    NSURL *libraryDir = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask].firstObject;
    NSString *logsDir = [libraryDir.path stringByAppendingPathComponent:@"Logs"];
    
    BOOL ret = [[NSFileManager defaultManager] fileExistsAtPath:logsDir];
    if (!ret) {
        ret = [[NSFileManager defaultManager] createDirectoryAtPath:logsDir withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    if (ret) {
        NSString *logFileName = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingPathExtension:@"log"];
        NSString *logFilePath = [logsDir stringByAppendingPathComponent:logFileName];
        
        freopen(logFilePath.fileSystemRepresentation, "a+", stdout);
        freopen(logFilePath.fileSystemRepresentation, "a+", stderr);
    }
}

@end
