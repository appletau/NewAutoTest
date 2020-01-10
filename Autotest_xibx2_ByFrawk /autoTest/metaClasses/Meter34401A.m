//
//  Meter34401A.m
//  autoTest
//
//  Created by TOM on 13/5/9.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "Meter34401A.h"

@implementation Meter34401A
@synthesize isReady;

-(void)DEMO
{
    NSLog(@"DMM query volt = %f",[self queryByCommand:@"MEASure:VOLTage:DC?"]);
    NSLog(@"DMM volt = %f",[self getVoltageDC]);
    NSLog(@"DMM resistance = %f",[self getResistance]);
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

-(double)getResistance
{
   // [gpib writeToGPIB:@"INPut:IMPedance:AUTO OFF"];
    [self IBCLR];
    
    return [self queryByCommand:@"MEASure:RESistance?"];
}

-(double)getVoltageDC
{
    return [self queryByCommand:@"MEASure:VOLTage:DC?"];
}

-(double)getCurrentDC
{
    return [self queryByCommand:@"MEASure:CURRent:DC?"];
}

-(double)getFrequence
{
    return [self queryByCommand:@"MEASure:FREQuency?"];
}

-(double)getCurrentDC_LL
{
    [gpib writeToGPIB:@"CONF:CURR:DC 1, DEF"];
    return [self queryByCommand:@"READ?"];
}

-(double)getCurrentDC_MAX
{
    [gpib writeToGPIB:@"CONF:CURR:DC MAX, DEF"];
    return [self queryByCommand:@"READ?"];
}

-(double)getRES_MAX
{
    [self IBCLR];
    
    [gpib writeToGPIB:@"CONF:RES MAX, DEF"];
    return [self queryByCommand:@"READ?"];
}

-(void)IBCLR
{
    [gpib IBCLR];
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

-(double)getDiodeChecking
{
    [gpib writeToGPIB:@"CONF:DIOD"];
    return [self queryByCommand:@"READ?"];
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
