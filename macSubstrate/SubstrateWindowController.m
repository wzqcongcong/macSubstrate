//
//  SubstrateWindowController.m
//  macSubstrate
//
//  Created by GoKu on 06/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstrateWindowController.h"
#import "SubstratePluginToInstallViewController.h"
#import "SubstratePluginUninstallViewController.h"
#import "SubstrateSettingsViewController.h"

@interface SubstrateWindowController () <NSWindowDelegate, SubstratePluginInstallObserver>

@property (weak) IBOutlet NSToolbarItem     *toolbarItemToInstall;
@property (weak) IBOutlet NSToolbarItem     *toolbarItemInstalled;
@property (weak) IBOutlet NSToolbarItem     *toolbarItemSettings;
@property (nonatomic, weak) NSToolbarItem   *lastSelectedToolbarItem;

@property (nonatomic, strong) SubstratePluginToInstallViewController    *toInstallVC;
@property (nonatomic, strong) SubstratePluginUninstallViewController    *installedVC;
@property (nonatomic, strong) SubstrateSettingsViewController           *settingsVC;

@end

@implementation SubstrateWindowController

+ (instancetype)sharedController
{
    static SubstrateWindowController *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SubstrateWindowController alloc] init];
        [sharedInstance close];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super initWithWindowNibName:@"SubstrateWindowController"];
    if (self) {
        _toInstallVC = [[SubstratePluginToInstallViewController alloc] init];
        _installedVC = [[SubstratePluginUninstallViewController alloc] init];
        _settingsVC = [[SubstrateSettingsViewController alloc] init];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.window.delegate = self;
    
    self.toInstallVC.view.hidden = NO;
    self.installedVC.view.hidden = NO;
    self.settingsVC.view.hidden = NO;
    self.toInstallVC.observer = self;
    
    self.lastSelectedToolbarItem = nil;
    
    self.window.toolbar.selectedItemIdentifier = self.toolbarItemToInstall.itemIdentifier;
    [self clickToolbarItemToInstall:self.toolbarItemToInstall];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
}

- (void)openToInstall
{
    [self showWindow:nil];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    self.window.toolbar.selectedItemIdentifier = self.toolbarItemToInstall.itemIdentifier;
    [self clickToolbarItemToInstall:self.toolbarItemToInstall];
}

- (void)openInstalled
{
    [self showWindow:nil];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    self.window.toolbar.selectedItemIdentifier = self.toolbarItemInstalled.itemIdentifier;
    [self clickToolbarItemInstalled:self.toolbarItemInstalled];
}

- (void)openSettings
{
    [self showWindow:nil];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    self.window.toolbar.selectedItemIdentifier = self.toolbarItemSettings.itemIdentifier;
    [self clickToolbarItemSettings:self.toolbarItemSettings];
}

- (IBAction)clickToolbarItemToInstall:(id)sender
{
    if (self.lastSelectedToolbarItem != sender) {
        [self.toInstallVC prepareUI];
        [self switchToSubview:self.toInstallVC.view withAnimaiton:YES];
    }
    
    self.lastSelectedToolbarItem = sender;
}

- (IBAction)clickToolbarItemInstalled:(id)sender
{
    if (self.lastSelectedToolbarItem != sender) {
        [self.installedVC prepareUI];
        [self switchToSubview:self.installedVC.view withAnimaiton:YES];
    }
    
    self.lastSelectedToolbarItem = sender;
}

- (IBAction)clickToolbarItemSettings:(id)sender
{
    if (self.lastSelectedToolbarItem != sender) {
        [self.settingsVC prepareUI];
        [self switchToSubview:self.settingsVC.view withAnimaiton:YES];
    }
    
    self.lastSelectedToolbarItem = sender;
}

- (void)switchToSubview:(NSView *)subview withAnimaiton:(BOOL)animation
{
    NSView *windowView = self.window.contentView;
    for (NSView *view in windowView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat oldHeight = windowView.frame.size.height;
    CGFloat oldWidth = windowView.frame.size.width;
    
    [windowView addSubview:subview];
    CGFloat newHeight = subview.frame.size.height;
    CGFloat newWidth = subview.frame.size.width;
    
    CGFloat deltaHeight = newHeight - oldHeight;
    CGFloat deltaWidth = newWidth - oldWidth;
    
    NSPoint origin = subview.frame.origin;
    origin.y -= deltaHeight;
    // no need to change for origin.x
    // because the default NSAutoresizingMaskOptions of subview is: NSViewMaxXMargin + NSViewMinYMargin
    // that means: MinX is fixed, MaxY is fixed.
    [subview setFrameOrigin:origin];
    
    NSRect frame = self.window.frame;
    frame.size.height += deltaHeight;
    frame.origin.y -= deltaHeight;
    frame.size.width += deltaWidth;
    [self.window setFrame:frame display:YES animate:animation];
}

- (void)didInstallPlugin:(NSString *)pluginPath
{
    if (self.lastSelectedToolbarItem == self.toolbarItemInstalled) {
        [self.installedVC prepareUI];
    }
}

@end
