//
//  SubstrateInstaller.h
//  macSubstrate
//
//  Created by GoKu on 16/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubstrateConstants.h"

@interface SubstrateInstaller : NSObject <SubstrateInstallerProtocol, NSXPCListenerDelegate>

@property (nonatomic, strong) NSXPCListener *listener;

- (void)run;

@end
