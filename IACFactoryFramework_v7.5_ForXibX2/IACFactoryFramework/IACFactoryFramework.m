//
//  IACFactoryFramework.m
//  IACFactoryFramework
//
//  Created by Li Richard on 1/23/14.
//  Copyright (c) 2014 Richard Li. All rights reserved.
//

#import "IACFactoryFramework.h"
#import <Sparkle/SUUpdater.h>

@implementation IACFactoryFramework


+(void)updateApp
{
    
    NSLog(@"cu: %@,Main %@",[[NSBundle bundleForClass:[self class]] bundlePath],[[NSBundle mainBundle] bundlePath]);
    
    SUUpdater *updater = [SUUpdater updaterForBundle:[NSBundle mainBundle]];
    [updater checkForUpdates:nil];

    
}

+(int)majorVersion
{
    return 7;
}

+(int)minorVersion
{
 
    return 5;
}

@end
