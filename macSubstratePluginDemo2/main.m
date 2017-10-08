//
//  main.m
//  macSubstratePluginDemo2
//
//  Created by GoKu on 08/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

__attribute__((constructor))
void macSubstratePluginDemo2()
{
    NSLog(@"%s: hello %@ (%d), I am in :)", __FUNCTION__, [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"], getpid());
}
