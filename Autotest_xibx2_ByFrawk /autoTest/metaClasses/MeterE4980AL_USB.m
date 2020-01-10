//
//  MeterE4980AL_USB.m
//  autoTest
//
//  Created by ANG on 2017/4/18.
//  Copyright © 2017年 TOM. All rights reserved.
//

#import "MeterE4980AL_USB.h"

@implementation MeterE4980AL_USB
@synthesize isReady;
-(void)DEMO
{
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


#pragma mark MeterE4980AL
- (double)setMeterParameter:(NSString *)currentFunc
{
    //打开设置界面
    [visaUSB writeToUSB:@"DISP:PAGE MSET"];
    //设置功能
    [visaUSB writeToUSB:[NSString stringWithFormat:@"FUNC:IMP %@",currentFunc]];
    //返回主界面
    [visaUSB writeToUSB:@"DISP:PAGE MEAS"];
    
    //读数
    [visaUSB writeToUSB:@"FETCh?"];
    usleep(500000);
    NSString *str =  [visaUSB readFromUSBreturnStr];
    return [str componentsSeparatedByString:@","][0].doubleValue;
}

//读电阻
-(double)getResistance
{
    return [self setMeterParameter:@"RX"];
}

//读并联电感
-(double)getInductanceP
{
    return [self setMeterParameter:@"LPD"];
}

//读串联电感
-(double)getInductanceS
{
    return [self setMeterParameter:@"LSD"];
}

//读并联电容
-(double)getCapacitanceP
{
    return [self setMeterParameter:@"CPD"];
}

//读串联电感电容
-(double)getCapacitanceS
{
    return [self setMeterParameter:@"CSD"];
}

@end
