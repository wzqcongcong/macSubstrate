//
//  SubstrateInstaller.m
//  macSubstrate
//
//  Created by GoKu on 16/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstrateInstaller.h"

@implementation SubstrateInstaller

- (instancetype)init
{
    self = [super init];
    if (self) {
        _listener = [[NSXPCListener alloc] initWithMachServiceName:kSubstrateInstallerBundleID];
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

- (void)installSubstrateFramework:(NSString *)frameworkPath
                    completeBlock:(void(^)(BOOL success))completeBlock
{
    NSLog(@"%s", __FUNCTION__);
    
    if (frameworkPath.length <= 0) {
        NotifyFailureAndReturn
    }
    
    BOOL ret = YES;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:kSubstrateFrameworkDirPath]) {
        ret = [[NSFileManager defaultManager] createDirectoryAtPath:kSubstrateFrameworkDirPath
                                        withIntermediateDirectories:YES
                                                         attributes:nil
                                                              error:NULL];
    }
    
    NSString *installPath = [kSubstrateFrameworkDirPath stringByAppendingPathComponent:kSubstrateFrameworkName];
    if (ret) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:installPath]) {
            ret = [[NSFileManager defaultManager] removeItemAtPath:installPath error:NULL];
        }
    }
    
    if (ret) {
        ret = [[NSFileManager defaultManager] copyItemAtPath:frameworkPath toPath:installPath error:NULL];
    }
    
    completeBlock(ret);
}

#pragma mark - NSXPCListenerDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
    assert(listener == self.listener);
    assert(newConnection);
    
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SubstrateInstallerProtocol)];
    newConnection.exportedObject = self;
    [newConnection resume];
    
    return YES;
}

@end
