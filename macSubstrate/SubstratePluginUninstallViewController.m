//
//  SubstratePluginUninstallViewController.m
//  macSubstrate
//
//  Created by GoKu on 08/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import "SubstratePluginUninstallViewController.h"
#import "SubstrateConstants.h"
#import "SubstratePluginManager.h"
#import "SubstratePlugin.h"
#import "SubstratePluginUninstallCellView.h"
#import "SubstrateUtility.h"

@interface SubstratePluginUninstallViewController () <NSTableViewDataSource, NSTabViewDelegate>

@property (weak) IBOutlet NSView                *subviewInstalled;
@property (weak) IBOutlet NSTableView           *tableView;
@property (weak) IBOutlet NSButton              *workingMask;
@property (weak) IBOutlet NSProgressIndicator   *workingSpin;

@property (nonatomic, strong) NSMutableArray    *displayList;
@property (nonatomic, assign) BOOL              working;

@end

@implementation SubstratePluginUninstallViewController

- (instancetype)init
{
    self = [super initWithNibName:@"SubstratePluginUninstallViewController" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)prepareUI
{
    [self updateStatus];
    
    NSArray *list = [SubstratePluginManager getInstalledPluginList];
    list = [list sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        BOOL ascending = YES;
        NSString *key = @"Target App";
        NSSortDescriptor *sortDescriptor = self.tableView.sortDescriptors.firstObject;
        if (sortDescriptor) {
            ascending = sortDescriptor.ascending;
            key = sortDescriptor.key;
        }
        
        SubstratePlugin *plugin1 = (ascending ? obj1 : obj2);
        SubstratePlugin *plugin2 = (ascending ? obj2 : obj1);
        
        NSString *targetAppName1 = [SubstrateUtility getAppNameFromBundleID:plugin1.targetAppBundleID];
        NSString *targetAppName2 = [SubstrateUtility getAppNameFromBundleID:plugin2.targetAppBundleID];
        
        if ([key isEqualToString:@"Target App"]) {
            NSComparisonResult ret = [targetAppName1 localizedCompare:targetAppName2];
            if (ret == NSOrderedSame) {
                return [plugin1.pluginFileName localizedCompare:plugin2.pluginFileName];
            } else {
                return ret;
            }
        } else {
            NSComparisonResult ret = [plugin1.pluginFileName localizedCompare:plugin2.pluginFileName];
            if (ret == NSOrderedSame) {
                return [targetAppName1 localizedCompare:targetAppName2];
            } else {
                return ret;
            }
        }
    }];
    
    self.displayList = [NSMutableArray arrayWithArray:list];
    [self.tableView reloadData];
}

- (void)updateStatus
{
    if (self.working) {
        self.workingMask.hidden = NO;
        [self.workingSpin startAnimation:nil];
    } else {
        self.workingMask.hidden = YES;
        [self.workingSpin stopAnimation:nil];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.displayList.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ((row < 0) || (row >= self.displayList.count)) {
        return nil;
    }
    
    SubstratePlugin *plugin = self.displayList[row];
    
    if ([tableColumn.identifier isEqualToString:@"Target App"]) {
        NSTableCellView *cellView = [self.tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        cellView.imageView.image = [SubstrateUtility getAppIconFromBundleID:plugin.targetAppBundleID];
        cellView.textField.stringValue = [SubstrateUtility getAppNameFromBundleID:plugin.targetAppBundleID];
        return cellView;
        
    } else if ([tableColumn.identifier isEqualToString:@"Plugin Name"]) {
        NSTableCellView *cellView = [self.tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        cellView.textField.stringValue = plugin.pluginFileName;
        return cellView;
        
    } else if ([tableColumn.identifier isEqualToString:@"Uninstall Action"]) {
        SubstratePluginUninstallCellView *cellView = [self.tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        return cellView;
        
    } else {
        return nil;
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors
{
    [self prepareUI];
}

- (IBAction)clickUninstallButton:(id)sender
{
    if (self.working) {
        return;
    }
    
    NSInteger row = [self.tableView rowForView:(NSButton *)sender];
    if ((row < 0) || (row >= self.displayList.count)) {
        return;
    }
    
    SubstratePlugin *plugin = self.displayList[row];
    NSString *pluginPath = [[kSubstratePluginsInstallDirName stringByAppendingPathComponent:plugin.targetAppBundleID] stringByAppendingPathComponent:plugin.pluginFileName];
    
    [self onUninstallationBegin:pluginPath];
    [[SubstratePluginManager sharedManager] uninstallPlugin:pluginPath
                                              completeBlock:^(BOOL success) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [self onUninstallationEnd:pluginPath success:success];
                                                  });
                                              }];
}

- (void)onUninstallationBegin:(NSString *)pluginPath
{
    NSLog(@"uninstall plugin begin: %@", pluginPath);
    
    self.working = YES;
    [self updateStatus];
}

- (void)onUninstallationEnd:(NSString *)pluginPath success:(BOOL)success
{
    NSLog(@"uninstall plugin end: %d", success);
    
    self.working = NO;
    [self updateStatus];
    
    if (success) {
        for (SubstratePlugin *plugin in self.displayList) {
            if ([pluginPath isEqualToString:[[kSubstratePluginsInstallDirName stringByAppendingPathComponent:plugin.targetAppBundleID] stringByAppendingPathComponent:plugin.pluginFileName]]) {
                
                NSUInteger row = [self.displayList indexOfObject:plugin];
                [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row]
                                      withAnimation:NSTableViewAnimationSlideUp];
                [self.displayList removeObject:plugin];
                
                return;
            }
        }
    }
}

@end
