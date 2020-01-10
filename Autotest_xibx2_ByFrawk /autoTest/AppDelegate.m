//
//  AppDelegate.m
//  autoTest
//
//  Created by TOM on 13/4/16.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "AppDelegate.h"
#import <IACFactoryFramework/PlistIO.h>
@implementation AppDelegate
@synthesize window;
- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    signal(SIGPIPE, &signalHandler);
    signal(SIGABRT, &signalHandler);
}

-(void)applicationWillTerminate:(NSNotification *)notification
{

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
