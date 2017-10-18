//
//  SubstrateWindowController.h
//  macSubstrate
//
//  Created by GoKu on 06/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SubstrateWindowController : NSWindowController

+ (instancetype)sharedController;

- (void)openToInstall;
- (void)openInstalled;
- (void)openSettings;

@end
