//
//  SubstrateEngineProxy.m
//  macSubstrate
//
//  Created by GoKu on 29/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstrateEngineProxy.h"

@interface SubstrateEngineProxy ()
{
    NSXPCConnection *_installerConnection;
    NSXPCConnection *_helperConnection;
}
@end

@implementation SubstrateEngineProxy

+ (instancetype)sharedProxy
{
    static SubstrateEngineProxy *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SubstrateEngineProxy alloc] init];
    });
    return sharedInstance;
}

- (id<SubstrateInstallerProtocol>)getInstallerWithErrorHandler:(void (^)(NSError *error))errorHandler
{
    _installerConnection = [[NSXPCConnection alloc] initWithMachServiceName:kSubstrateInstallerBundleID options:NSXPCConnectionPrivileged];
    _installerConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SubstrateInstallerProtocol)];
    [_installerConnection resume];
    
    id<SubstrateInstallerProtocol> installer = [_installerConnection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        errorHandler(error);
    }];
    
    return installer;
}

- (id<SubstrateHelperProtocol>)getHelperWithErrorHandler:(void (^)(NSError *error))errorHandler
{
    _helperConnection = [[NSXPCConnection alloc] initWithMachServiceName:kSubstrateHelperBundleID options:NSXPCConnectionPrivileged];
    _helperConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SubstrateHelperProtocol)];
    [_helperConnection resume];
    
    id<SubstrateHelperProtocol> helper = [_helperConnection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        errorHandler(error);
    }];
    
    return helper;
}

@end
