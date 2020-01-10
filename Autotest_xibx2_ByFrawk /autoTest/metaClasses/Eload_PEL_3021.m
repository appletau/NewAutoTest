//
//  Meter34401A.m
//  autoTest
//
//  Created by TOM on 13/5/9.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "Eload_PEL_3021.h"

@implementation Eload_PEL_3021
@synthesize isReady;

-(void)DEMO
{
    NSLog(@"%@",[self eloadTestForDemo]);
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
        {
            NSLog(@"eload sn:%@",[self eloadInitial]);
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
    [gpib release];
    [super dealloc];
}

-(NSString*)eloadInitial
{
    [gpib writeToGPIB:@":input Off"];
    [gpib writeToGPIB:@"*CLS"];
    [gpib writeToGPIB:@"*IDN?"];
    return [gpib readFromGPIBreturnStr];
}

-(double)measureVoltage
{
    [gpib writeToGPIB:@":Measure:Voltage?"];
    return [gpib readFromGPIB];
}

-(double)measureCurrent
{
    [gpib writeToGPIB:@":Measure:current?"];
    return [gpib readFromGPIB];
}

-(double)measurePower
{
    [gpib writeToGPIB:@":Measure:Power?"];
    return [gpib readFromGPIB];
}

-(NSString*)eloadTestForDemo
{
    [gpib writeToGPIB:@":MODE CC"];     //CC/CV/CR/CP
    [gpib writeToGPIB:@":CRANGE Low"];  //Hight/Middle/Low
    [gpib writeToGPIB:@":CURRENT:VA MIN"];
    [gpib writeToGPIB:@":CURRENT:SRATE 0.025"];
    [gpib writeToGPIB:@":input ON"];   //On/Off
    
    NSMutableString *readings=[[[NSMutableString alloc] init] autorelease];
    
    for(int i=0;i<120;i+=10)
    {
        sleep(3);
        [gpib writeToGPIB:[NSString stringWithFormat:@"CURRENT:VA %f",(i*0.001)]];
        NSString *testInfo=[NSString stringWithFormat:@"volt(V):%f curr(A):%f power(W):%f",[self measureVoltage],[self measureCurrent],[self measurePower]];
        [readings appendFormat:@"%d [%@] ",i,testInfo];
     }
    
    [gpib writeToGPIB:@":input Off"];
    
    return [NSString stringWithString:readings];
}

-(void)IBCLR
{
    [gpib IBCLR];
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
