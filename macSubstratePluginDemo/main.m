//
//  main.m
//  macSubstratePluginDemo
//
//  Created by GoKu on 29/09/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

__attribute__((constructor))
void macSubstratePluginDemo()
{
    NSLog(@"%s: hello %@ (%d), I am in :)", __FUNCTION__, [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"], getpid());
}
