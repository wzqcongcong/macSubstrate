//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import <Foundation/Foundation.h>
#import "CaptainHook.h"

__attribute__((constructor))
void ___PACKAGENAMEASIDENTIFIER___Entry()
{
    NSLog(@"%s: hello %@ (%d), I am in :)", __FUNCTION__, [[NSBundle mainBundle] bundleIdentifier], getpid());
}
