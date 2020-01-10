//
//  GetDFUFlag.m
//  autoTest
//
//  Created by May on 13/7/1.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "DFU.h"
//#define kOurProductID								4647 //0x1227 as DFU Device
//#define kOuriPodProductString						"Apple Mobile Device (DFU Mode)"

@implementation DFU
@synthesize isReady;
@synthesize isRomoved;
@synthesize isAdded;

-(void)DEMO
{
    NSLog(@"DFU add = %d",[self isAdded]);
    NSLog(@"DFU remove = %d",[self isRomoved]);
}

-(id)init:(int)ProductID productName:(NSString *)ProductString
{
    if(self=[super init])
    {
        [self cleanFlags];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setAddedFlag)
                                                     name:@"FLAG_STATE_ADDED_DFU"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setRomovedFlag)
                                                     name:@"FLAG_STATE_REMOVED_DFU"
                                                   object:nil];
        //arg1->product ID arg2->product pattern string
        IOdfu=[[IOReg alloc] init:ProductID ProductStr:(__bridge CFStringRef)ProductString testMode:@"mode_DFU"];
        if (ProductID > 0 && [ProductString length] > 0)
            isReady = true ;
        else
            NSLog(@"DUF is not ready to use");
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
    [IOdfu release];
    [super dealloc];
}

-(void)cleanFlags
{
    isAdded=NO;
    isRomoved=NO;
}

-(void)setAddedFlag
{
    [self cleanFlags];
    isAdded=YES;
    NSLog(@"DFU addingFlag setted");
}

-(void)setRomovedFlag
{
    [self cleanFlags];
    isRomoved=YES;
    NSLog(@"DFU removingFlag setted");
}
@end
