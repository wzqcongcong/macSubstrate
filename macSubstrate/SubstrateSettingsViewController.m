//
//  SubstrateSettingsViewController.m
//  macSubstrate
//
//  Created by GoKu on 08/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstrateSettingsViewController.h"
#import "SubstrateUtility.h"

@interface SubstrateSettingsViewController ()

@property (weak) IBOutlet NSView    *subviewSettings;
@property (weak) IBOutlet NSButton  *checkLoginItem;

@end

@implementation SubstrateSettingsViewController

- (instancetype)init
{
    self = [super initWithNibName:@"SubstrateSettingsViewController" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)prepareUI
{
    self.checkLoginItem.state = [SubstrateUtility loginItemEnabled] ? NSOnState : NSOffState;
}

- (IBAction)clickCheckLoginItem:(id)sender
{
    NSInteger stateAfterClick = self.checkLoginItem.state;
    NSInteger stateBeforeClick = 1 - stateAfterClick;
    
    NSLog(@"login item: %ld", (long)stateAfterClick);
    
    [SubstrateUtility setLoginItemEnabled:(stateAfterClick == NSOnState)];
    BOOL ret = [SubstrateUtility setupLoginItem];
    if (!ret) {
        self.checkLoginItem.state = stateBeforeClick;
        [SubstrateUtility setLoginItemEnabled:(stateBeforeClick == NSOnState)];
    }
}

@end
