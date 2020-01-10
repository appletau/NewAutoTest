//
//  Eload_PEL_3021_USB.m
//  autoTest
//
//  Created by ANG on 2018/1/9.
//  Copyright © 2018年 TOM. All rights reserved.
//

#import "Eload_PEL_3021_USB.h"

@implementation Eload_PEL_3021_USB
@synthesize isReady;

- (void)DEMO
{
    NSLog(@"%@",[self eloadTestForDemo]);
}

-(id)init:(NSString*)usbName
{
    visaUSB = [[VisaUSB alloc]init];
    [visaUSB openUSB:usbName];
    isReady = visaUSB.isUSBopening;
    
    
    if (!isReady)
        NSLog(@"%@ (%@) is not ready to use",[self className],usbName);
    else
    {
        NSLog(@"eload sn:%@",[self eloadInitial]);
        NSLog(@"%@ (%@) is ready to use",[self className],usbName);
    }
    
    return self;
}

-(id)initWithArg:(NSDictionary *)dic
{
    id tmp = nil;
    tmp = [self init:[dic objectForKey:@"PATH"] ];
    return tmp;
}


-(NSString*)eloadInitial
{
    [visaUSB writeToUSB:@":input Off\n"];
    [visaUSB writeToUSB:@"*CLS\n"];
    [visaUSB writeToUSB:@"*IDN?\n"];
    return [visaUSB readFromUSBreturnStr];
}

-(double)measureVoltage
{
    [visaUSB writeToUSB:@":Measure:Voltage?\n"];
    return [visaUSB readFromUSB];
}

-(double)measureCurrent
{
    [visaUSB writeToUSB:@":Measure:current?\n"];
    return [visaUSB readFromUSB];
}

-(double)measurePower
{
    [visaUSB writeToUSB:@":Measure:Power?\n"];
    return [visaUSB readFromUSB];
}

-(NSString*)eloadTestForDemo
{
    [visaUSB writeToUSB:@":MODE CC\n"];     //CC/CV/CR/CP
    [visaUSB writeToUSB:@":CRANGE Low\n"];  //Hight/Middle/Low
    [visaUSB writeToUSB:@":CURRENT:VA MIN\n"];
    [visaUSB writeToUSB:@":CURRENT:SRATE 0.025\n"];
    [visaUSB writeToUSB:@":input ON\n"];   //On/Off
    
    NSMutableString *readings=[[[NSMutableString alloc] init] autorelease];
    
    for(int i=0;i<120;i+=10)
    {
        sleep(3);
        [visaUSB writeToUSB:[NSString stringWithFormat:@"CURRENT:VA %f\n",(i*0.001)]];
        NSString *testInfo=[NSString stringWithFormat:@"volt(V):%f curr(A):%f power(W):%f",[self measureVoltage],[self measureCurrent],[self measurePower]];
        [readings appendFormat:@"%d [%@] ",i,testInfo];
        NSLog(@"%@",testInfo);
    }
    
    [visaUSB writeToUSB:@":input Off\n"];
    
    return [NSString stringWithString:readings];
}

-(void)dealloc
{
    [visaUSB closeUSB];
    [visaUSB release];
    [super dealloc];
}

-(void)closeUSB
{
    [visaUSB closeUSB];
    isReady = FALSE;
}

-(double)queryByCommand:(NSString *)cmd
{
    [visaUSB writeToUSB:cmd];
    usleep(500000);
    return [visaUSB readFromUSB];
}


@end
