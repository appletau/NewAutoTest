//
//  AppDelegate.m
//  autoTest
//
//  Created by TOM on 13/4/16.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "AppDelegate.h"
#import "PlistIO.h"
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    signal(SIGPIPE, &signalHandler);
    signal(SIGABRT, &signalHandler);
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

void signalHandler(int signal)
{
    NSLog(@"Get Ssignal %d",signal);
}
@end
