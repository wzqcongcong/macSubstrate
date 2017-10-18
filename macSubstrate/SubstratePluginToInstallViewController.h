//
//  SubstratePluginToInstallViewController.h
//  macSubstrate
//
//  Created by GoKu on 08/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SubstratePluginInstallObserver <NSObject>

@required
- (void)didInstallPlugin:(NSString *)pluginPath;

@end

@interface SubstratePluginToInstallViewController : NSViewController

@property (nonatomic, weak) id<SubstratePluginInstallObserver> observer;

- (void)prepareUI;

@end
