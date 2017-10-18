//
//  SubstratePluginToInstallViewController.m
//  macSubstrate
//
//  Created by GoKu on 08/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstratePluginToInstallViewController.h"
#import "SubstratePluginManager.h"
#import "SubstratePlugin.h"
#import "SubstratePluginToInstallDragView.h"
#import "SubstrateUtility.h"

@interface SubstratePluginToInstallViewController () <SubstratePluginToInstallDragViewDelegate>

@property (weak) IBOutlet NSView                            *subviewToInstall;
@property (weak) IBOutlet NSTextField                       *installTip;
@property (weak) IBOutlet NSProgressIndicator               *workingSpin;
@property (weak) IBOutlet NSView                            *displayInfo;
@property (weak) IBOutlet NSTextField                       *displayInfoPluginName;
@property (weak) IBOutlet NSTextField                       *displayInfoTargetApp;
@property (weak) IBOutlet NSTextField                       *displayInfoAuthorName;
@property (weak) IBOutlet NSTextField                       *displayInfoAuthorEmail;
@property (weak) IBOutlet NSTextField                       *displayInfoCodeSign;
@property (weak) IBOutlet SubstratePluginToInstallDragView  *dragAndDropView;
@property (weak) IBOutlet NSButton                          *importPlugin;

@property (nonatomic, strong) NSString                      *installingPluginPath;
@property (nonatomic, assign) BOOL                          working;

@end

@implementation SubstratePluginToInstallViewController

- (instancetype)init
{
    self = [super initWithNibName:@"SubstratePluginToInstallViewController" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)prepareUI
{
    [self updateStatus];
    
    self.installTip.stringValue = (self.working ? @"Installing plugin ..." : @"Import or drag in a plugin to install");
    self.installTip.textColor = [NSColor labelColor];
    
    if (self.working) {
        [self updateDisplayInfoWith:self.installingPluginPath];
    }
    self.displayInfo.hidden = !self.working;
}

- (void)updateStatus
{
    if (self.working) {
        self.importPlugin.enabled = NO;
        [self.workingSpin startAnimation:nil];
    } else {
        self.importPlugin.enabled = YES;
        [self.workingSpin stopAnimation:nil];
    }
}

- (void)updateDisplayInfoWith:(NSString *)pluginPath
{
    SubstratePlugin *plugin = [SubstratePlugin getSubstratePluginWithPath:pluginPath];
    
    self.displayInfoPluginName.stringValue = ((pluginPath.lastPathComponent.length > 0) ? pluginPath.lastPathComponent : @"Unknown");
    self.displayInfoPluginName.textColor = ((plugin.pluginFileName.length > 0) ? [NSColor labelColor] : [NSColor redColor]);
    
    self.displayInfoTargetApp.stringValue = ((plugin.targetAppBundleID.length > 0) ? [SubstrateUtility getAppNameFromBundleID:plugin.targetAppBundleID] : @"Unknown");
    self.displayInfoTargetApp.textColor = ((plugin.targetAppBundleID.length > 0) ? [NSColor labelColor] : [NSColor redColor]);
    
    self.displayInfoAuthorName.stringValue = ((plugin.pluginAuthorName.length > 0) ? plugin.pluginAuthorName : @"Unknown");
    self.displayInfoAuthorName.textColor = ((plugin.pluginAuthorName.length > 0) ? [NSColor labelColor] : [NSColor redColor]);
    
    self.displayInfoAuthorEmail.stringValue = ((plugin.pluginAuthorEmail.length > 0) ? plugin.pluginAuthorEmail : @"Unknown");
    self.displayInfoAuthorEmail.textColor = ((plugin.pluginAuthorEmail.length > 0) ? [NSColor labelColor] : [NSColor redColor]);
    
    BOOL validCodeSign = [SubstratePlugin verifyCodeSignatureWithPath:pluginPath];
    self.displayInfoCodeSign.stringValue = (validCodeSign ? @"✔︎ Valid" : @"✘ Invalid");
    self.displayInfoCodeSign.textColor = (validCodeSign ? [NSColor blueColor] : [NSColor redColor]);
}

- (IBAction)clickImportPlugin:(id)sender
{
    self.importPlugin.enabled = NO;
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.allowedFileTypes = [SubstratePlugin getValidPluginFileTypes];
    openPanel.directoryURL = [[NSFileManager defaultManager] homeDirectoryForCurrentUser];
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    openPanel.canCreateDirectories = NO;
    openPanel.showsHiddenFiles = NO;
    
    [openPanel beginSheetModalForWindow:self.view.window
                      completionHandler:^(NSInteger result) {
                          self.importPlugin.enabled = YES;
                          
                          if (result == NSFileHandlingPanelOKButton) {
                              NSLog(@"import to install plugin: %@", openPanel.URL.path);
                              [self installPlugin:openPanel.URL.path];
                          }
                      }];
}

- (BOOL)canDraggingPlugin
{
    return (!self.working && self.importPlugin.enabled);
}

- (void)draggingPluginEntered:(NSString *)pluginPath
{
    [self updateDisplayInfoWith:pluginPath];
    self.displayInfo.hidden = NO;
}

- (void)draggingPluginExited:(NSString *)pluginPath
{
    self.displayInfo.hidden = YES;
}

- (void)didFinishDraggingPlugin:(NSString *)pluginPath
{
    NSLog(@"drag to install plugin: %@", pluginPath);
    [self installPlugin:pluginPath];
}

- (void)installPlugin:(NSString *)pluginPath
{
    if (pluginPath.length <= 0) {
        return;
    }
    
    [self onInstallationBegin:pluginPath];
    [[SubstratePluginManager sharedManager] installPlugin:pluginPath
                                            completeBlock:^(BOOL success) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self onInstallationEnd:pluginPath success:success];
                                                });
                                            }];
}

- (void)onInstallationBegin:(NSString *)pluginPath
{
    NSLog(@"install plugin begin: %@", pluginPath);
    
    self.working = YES;
    self.installingPluginPath = pluginPath;
    [self updateStatus];
    
    self.installTip.stringValue = @"Installing plugin ...";
    self.installTip.textColor = [NSColor labelColor];
    
    [self updateDisplayInfoWith:pluginPath];
    self.displayInfo.hidden = NO;
}

- (void)onInstallationEnd:(NSString *)pluginPath success:(BOOL)success
{
    NSLog(@"install plugin end: %d", success);
    
    self.working = NO;
    self.installingPluginPath = nil;
    [self updateStatus];
    
    self.installTip.stringValue = [NSString stringWithFormat:@"%@ to install plugin", (success ? @"Succeed" : @"Failed")];
    self.installTip.textColor = (success ? [NSColor blueColor] : [NSColor redColor]);
    
    if (success) {
        [self.observer didInstallPlugin:pluginPath];
    }
}

@end
