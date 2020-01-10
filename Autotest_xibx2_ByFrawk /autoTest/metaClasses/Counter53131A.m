//
//  Counter53131A.m
//  autoTest
//
//  Created by May on 5/16/13.
//  Copyright (c) 2013 TOM. All rights reserved.
//

#import "Counter53131A.h"

@implementation Counter53131A
@synthesize isReady;

-(void)DEMO
{
    NSLog(@"counter freq with argument = %f",[self getFrequencyByArg:@"50 MHZ" resolution:@"1HZ"]);
    NSLog(@"counter query freq = %f",[self queryByCommand:@":MEASURE:FREQ?"]);
    NSLog(@"counter freq = %f",[self getFrequency]);
}

-(id)init:(int)address;
{
    if(self=[super init])
    {
        gpib = [[GPIB alloc]init];
        [gpib openGPIB:address];
        isReady=[gpib isGPIBopening];
        
        if (!isReady)
            NSLog(@"%@ (%d) is not ready to use",[self className],address);
        else
            NSLog(@"%@ (%d) is ready to use",[self className],address);
    }
    return self;
}

-(id)initWithArg:(NSDictionary *)dic
{
    id tmp = nil;
    tmp = [self init: [[dic objectForKey:@"GPIBINDEX"] intValue]];
	return tmp;
}

-(void)dealloc
{
    [gpib release];
    [super dealloc];
}

-(double)getFrequency
{
    return [self queryByCommand:@":MEASURE:FREQ?"];
}

-(double)getFrequencyByArg:(NSString*)expectedVal resolution:(NSString*)resoluVal
{
    return [self queryByCommand:[NSString stringWithFormat:@":MEASURE:FREQ? %@, %@",expectedVal,resoluVal]];//e.g. 50 MHZ 1HZ
}

-(double)queryByCommand:(NSString *)cmd
{
    double value=0;
    if([gpib writeToGPIB:cmd])
        value=[gpib readFromGPIB];
    return value;
}

-(BOOL)isQueryTimeOut
{
    if ([gpib isTimeout])
        return TRUE;
    return FALSE;
}

-(void)close
{
    if (gpib.isGPIBopening)
    {
        [gpib closeGPIB];
        isReady = false;
    }
}

@end
