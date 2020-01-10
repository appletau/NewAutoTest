//
//  PowerSupply.m
//  autoTest
//
//  Created by May on 13/6/27.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "PWR3631.h"

@implementation PWR3631
@synthesize isReady;


-(void)DEMO
{
    [self setP6V:3.3 ampere:1];
    [self setP25V:3.3 ampere:1];
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

-(void)setP6V:(float)V ampere:(float)I
{
    NSString *cmd=[NSString stringWithFormat:@"APPL P6V, %.1f, %.1f",V,I];
    if ([gpib writeToGPIB:cmd])
        NSLog(@"pwr-3631 seting ok");
}

-(void)setP25V:(float)V ampere:(float)I
{
    NSString *cmd=[NSString stringWithFormat:@"APPL P25V, %.1f, %.1f",V,I];
    if ([gpib writeToGPIB:cmd])
        NSLog(@"pwr-3631 seting ok");
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
