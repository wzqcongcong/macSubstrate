//
//  main.m
//  macSubstrateInstaller
//
//  Created by GoKu on 16/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubstrateInstaller.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        SubstrateInstaller *installer = [[SubstrateInstaller alloc] init];
        [installer run];
    }
    
    NSLog(@"%@ exits", [[NSBundle mainBundle] bundleIdentifier]);
    return 0;
}
