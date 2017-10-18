//
//  SubstrateEngineProxy.h
//  macSubstrate
//
//  Created by GoKu on 29/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubstrateHelper.h"

@interface SubstrateEngineProxy : NSObject

+ (instancetype)sharedProxy;

- (id<SubstrateInstallerProtocol>)getInstallerWithErrorHandler:(void (^)(NSError *error))errorHandler;
- (id<SubstrateHelperProtocol>)getHelperWithErrorHandler:(void (^)(NSError *error))errorHandler;

@end
