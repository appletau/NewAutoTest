//
//  PWR3615.m
//  autoTest
//
//  Created by May on 13/6/27.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "PWR3615GW.h"

@implementation PWR3615GW
@synthesize isReady;

-(void)DEMO
{
    [self setChannel:1 voltage:3.0 ampere:1];
    [self pwr_ONOFF:1 OCP_ONOFF:1];
    NSLog(@"pwr ch1 curr= %f",[self getCurrByChannel:1]);
    NSLog(@"pwr ch1 volt= %f",[self getVoltByChannel:1]);
    [self pwr_ONOFF:0 OCP_ONOFF:0];
}

-(id)init:(int)address
{
    if(self=[super init])
    {
        gpib = [[GPIB alloc]init];
        isReady=FALSE;
        
        if (address!=-1)
        {
            [gpib openGPIB:address];
            isReady=[gpib isGPIBopening];

            if (!isReady)
                NSLog(@"%@ (%d) is not ready to use",[self className],address);
            else
                NSLog(@"%@ (%d) is ready to use",[self className],address);
        }
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
    [gpib closeGPIB];
    [gpib release];
    [super dealloc];
}

-(void)pwrONOFF:(int)onOff
{
	if (![gpib writeToGPIB:[NSString stringWithFormat:@"OUTP:STAT %d", onOff]])
	{
		NSLog(@"%@ output:%d setting not ok",[self className],onOff);
	}
    usleep(200000);//0.2s
}

-(void)setChannel:(int)ch voltage:(float)V ampere:(float)I
{
    if ([gpib writeToGPIB:[NSString stringWithFormat:@"CHAN %d",ch]])
    {
        if ([gpib writeToGPIB:[NSString stringWithFormat:@"VOLT %.2f",V]])
        {
            if ([gpib writeToGPIB:[NSString stringWithFormat:@"CURR %.2f",I]])
			{
                NSLog(@"pwr-3615 seting ok");
			}
        }
    }
}

-(void)pwr_ONOFF:(int)onOff_pwr OCP_ONOFF:(int)onOff_OCP
{
	if ([gpib writeToGPIB:[NSString stringWithFormat:@"CURR:PROT:STAT %d", onOff_OCP]])
	{
		NSLog(@"current protect:%d",onOff_OCP);
	}
	usleep(20000);
	if ([gpib writeToGPIB:[NSString stringWithFormat:@"OUTP:STAT %d", onOff_pwr]])
	{
		NSLog(@"output:%d",onOff_pwr);
	}
}

-(double)getCurrByChannel:(int)ch
{
    if ([gpib writeToGPIB:[NSString stringWithFormat:@"CHAN %d",ch]])
    {
        if ([gpib writeToGPIB:@"MEAS:CURR?"])
        {
            return [gpib readFromGPIB];
		}
    }
    return -1;
}
-(double)getVoltByChannel:(int)ch
{
    if ([gpib writeToGPIB:[NSString stringWithFormat:@"CHAN %d",ch]])
    {
        if ([gpib writeToGPIB:@"MEAS:VOLT?"])
        {
            return [gpib readFromGPIB];
		}
    }
    return -1;
}

-(double)queryByCommand:(NSString *)cmd
{
    double value=0;
    if([gpib writeToGPIB:cmd])
        value=[gpib readFromGPIB];
    return value;
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
