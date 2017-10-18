//
//  SubstrateHelper.h
//  macSubstrateHelper
//
//  Created by GoKu on 28/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubstrateConstants.h"

@interface SubstrateHelper : NSObject <SubstrateHelperProtocol, NSXPCListenerDelegate>

@property (nonatomic, strong) NSXPCListener *listener;

- (void)run;

@end
