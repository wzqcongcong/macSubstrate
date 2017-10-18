//
//  SubstratePluginToInstallDragView.m
//  macSubstrate
//
//  Created by GoKu on 07/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstratePluginToInstallDragView.h"
#import "SubstratePlugin.h"

@implementation SubstratePluginToInstallDragView

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (void)dealloc
{
    [self unregisterDraggedTypes];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    if (![self.delegate canDraggingPlugin]) {
        return NSDragOperationNone;
    }
    
    NSString *pluginPath = [self getPluginPathFromDraggingInfo:sender];
    
    if (pluginPath.length > 0) {
        [self.delegate draggingPluginEntered:pluginPath];
        return NSDragOperationCopy;
        
    } else {
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    if (![self.delegate canDraggingPlugin]) {
        return;
    }
    
    [self.delegate draggingPluginExited:nil];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    if (![self.delegate canDraggingPlugin]) {
        return NO;
    }
    
    NSString *pluginPath = [self getPluginPathFromDraggingInfo:sender];
    
    if (pluginPath.length > 0) {
        [self.delegate didFinishDraggingPlugin:pluginPath];
        return YES;
        
    } else {
        return NO;
    }
}

- (NSString *)getPluginPathFromDraggingInfo:(id<NSDraggingInfo>)info
{
    NSArray *filePaths = [info.draggingPasteboard propertyListForType:NSFilenamesPboardType];
    if (filePaths.count != 1) {
        return nil;
    }
    
    NSString *filePath = filePaths.firstObject;
    if (![[SubstratePlugin getValidPluginFileTypes] containsObject:filePath.pathExtension]) {
        return nil;
    }
    
    return filePath;
}

@end
