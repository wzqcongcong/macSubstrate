//
//  main.m
//  macSubstrateHelper
//
//  Created by GoKu on 27/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubstrateHelper.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        SubstrateHelper *helper = [[SubstrateHelper alloc] init];
        [helper run];
    }
    
    NSLog(@"%@ exits", [[NSBundle mainBundle] bundleIdentifier]);
    return 0;
}
