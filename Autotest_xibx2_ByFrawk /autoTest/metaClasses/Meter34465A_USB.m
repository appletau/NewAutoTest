//
//  Meter34465A_USB.m
//  autoTest
//
//  Created by Wang Sky on 6/2/16.
//  Copyright © 2016 TOM. All rights reserved.
//

#import "Meter34465A_USB.h"

@implementation Meter34465A_USB

@synthesize isReady ;

-(void)DEMO
{
    NSLog(@"(USB)DMM query current = %f",[self queryByCommand:@"MEASure:CURRent:DC?"]);
    NSLog(@"(USB)DMM volt = %f",[self getVoltageDC]);
    NSLog(@"(USB)DMM resistance = %f",[self getResistance]);
}

-(id)init:(NSString*)usbName
{
    visaUSB = [[VisaUSB alloc]init];
    [visaUSB openUSB:usbName];
    isReady = visaUSB.isUSBopening;
            
    if (!isReady)
        NSLog(@"%@ (%@) is not ready to use",[self className],usbName);
    else
        NSLog(@"%@ (%@) is ready to use",[self className],usbName);
    
    return self;
}

-(id)initWithArg:(NSDictionary *)dic
{
    id tmp = nil;
    tmp = [self init:[dic objectForKey:@"PATH"] ];
    return tmp;
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

#pragma mark Meter34465A
-(double)getResistance
{
    // [gpib writeToGPIB:@"INPut:IMPedance:AUTO OFF"];
    
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
    [visaUSB writeToUSB:@"CONF:CURR:DC 1, DEF"];
    return [self queryByCommand:@"READ?"];
}

-(double)getCurrentDC_MAX
{
    [visaUSB writeToUSB:@"CONF:CURR:DC MAX, DEF"];
    return [self queryByCommand:@"READ?"];
}

-(double)getRES_MAX
{
    [visaUSB  writeToUSB:@"CONF:RES MAX, DEF"];
    return [self queryByCommand:@"READ?"];
}

-(double)getDiodeChecking
{
    [visaUSB writeToUSB:@"CONF:DIOD"];
    return [self queryByCommand:@"READ?"];
}


@end
