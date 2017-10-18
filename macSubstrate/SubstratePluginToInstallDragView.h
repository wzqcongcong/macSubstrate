//
//  SubstratePluginToInstallDragView.h
//  macSubstrate
//
//  Created by GoKu on 07/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SubstratePluginToInstallDragViewDelegate <NSObject>

@required
- (BOOL)canDraggingPlugin;
- (void)draggingPluginEntered:(NSString *)pluginPath;
- (void)draggingPluginExited:(NSString *)pluginPath;
- (void)didFinishDraggingPlugin:(NSString *)pluginPath;

@end

@interface SubstratePluginToInstallDragView : NSView

@property (nonatomic, weak) IBOutlet id<SubstratePluginToInstallDragViewDelegate> delegate;

@end
