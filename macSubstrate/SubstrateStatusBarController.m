//
//  SubstrateStatusBarController.m
//  macSubstrate
//
//  Created by GoKu on 06/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstrateStatusBarController.h"
#import "SubstrateWindowController.h"
#import "SUUpdater.h"

@interface SubstrateStatusBarController ()

@property (nonatomic, strong) NSStatusItem  *appStatusBar;

@property (strong) IBOutlet NSMenu          *statusBarMenu;
@property (weak) IBOutlet NSMenuItem        *menuItemToInstall;
@property (weak) IBOutlet NSMenuItem        *menuItemInstalled;
@property (weak) IBOutlet NSMenuItem        *menuItemSettings;
@property (weak) IBOutlet NSMenuItem        *menuItemCheckForUpdates;
@property (weak) IBOutlet NSMenuItem        *menuItemQuit;

@end

@implementation SubstrateStatusBarController

+ (instancetype)sharedController
{
    static SubstrateStatusBarController *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SubstrateStatusBarController alloc] init];
        sharedInstance.view.hidden = YES;
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super initWithNibName:@"SubstrateStatusBarController" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.appStatusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.appStatusBar.toolTip = [[NSRunningApplication currentApplication] localizedName];
    self.appStatusBar.image = [NSImage imageNamed:@"StatusBar"];
    self.appStatusBar.image.template = YES;
    self.appStatusBar.menu = self.statusBarMenu;
}

- (IBAction)clickMenuItemToInstall:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [[SubstrateWindowController sharedController] openToInstall];
}

- (IBAction)clickMenuItemInstalled:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [[SubstrateWindowController sharedController] openInstalled];
}

- (IBAction)clickMenuItemSettings:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [[SubstrateWindowController sharedController] openSettings];
}

- (IBAction)clickMenuItemCheckForUpdates:(id)sender
{
    [[SUUpdater sharedUpdater] checkForUpdates:sender];
}

- (IBAction)clickMenuItemQuit:(id)sender
{
    [NSApp terminate:self];
}

@end
