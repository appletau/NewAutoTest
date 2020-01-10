//
//  UDID.m
//  tryFramework
//
//  Created by May on 14/2/24.
//  Copyright (c) 2014年 Richard Li. All rights reserved.
//

#import "UDID.h"
//#define kOurProductID								4766 //0x129E as UDID Device
//#define kOuriPodProductString						"iPod"

@implementation UDID
@synthesize isReady;
@synthesize isRomoved;
@synthesize isAdded;
@synthesize devUDID;
@synthesize locactionID;

-(void)DEMO
{
    NSLog(@"UDID add = %d",[self isAdded]);
    // if isAdd is true, deviceUDID has a serial number
    NSLog(@"UDID serial number= %@",[self devUDID]);
    NSLog(@"UDID locaction = %@",[self locactionID]);
    NSLog(@"UDID remove = %d",[self isRomoved]);
}

-(id)init:(int)ProductID productName:(NSString *)ProductString
{
    if(self=[super init])
    {
        [self cleanFlags];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setAddedFlag:)
                                                     name:@"FLAG_STATE_ADDED_UDID"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setRomovedFlag)
                                                    name:@"FLAG_STATE_REMOVED_UDID"
                                                   object:nil];
        //arg1->product ID arg2->product pattern string
        IOudid=[[IOReg alloc] init:ProductID ProductStr:(__bridge CFStringRef)ProductString testMode:@"mode_UDID"];
        if (ProductID > 0 && [ProductString length] > 0)
        {
            devUDID = [[NSMutableString alloc] init];
            locactionID = [[NSMutableString alloc] init];
            isReady = true ;
        }
        else
            NSLog(@"UDID is not ready to use");
    }
    return self;
}

-(id)initWithArg:(NSDictionary *)dic
{
	id tmp = nil;
    tmp = [self init: [[dic objectForKey:@"ProductID"] intValue] productName:[dic objectForKey:@"ProductName"]];
	return tmp;
}

-(void)dealloc
{
    isReady = false;
    [IOudid release];
    [devUDID release];
    [locactionID release];
    [super dealloc];
}

-(void)cleanFlags
{
    isAdded=NO;
    isRomoved=NO;
}

-(void)setAddedFlag:(NSNotification *)_notification
{
    [self cleanFlags];
    isAdded=YES;
    
    NSDictionary *devRegInfo=(NSDictionary*)[_notification object];
    [devUDID setString:[devRegInfo objectForKey:@"udid"]];
    [locactionID setString:[devRegInfo objectForKey:@"locationID"]];
    NSLog(@"UDID addingFlag setted:%@ (loc=%@)",devUDID,locactionID);
}

-(void)setRomovedFlag
{
    [self cleanFlags];
    isRomoved=YES;
    NSLog(@"UDID romovingFlag setted");
}
@end
