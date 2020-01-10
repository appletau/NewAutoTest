//
//  PWR3615.h
//  autoTest
//
//  Created by May on 13/6/27.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPIB.h"
#import "Equipments.h"

@interface PWR3615GW : Equipments
{
    BOOL isReady;
    GPIB *gpib;
}
@property(readonly)BOOL isReady;
-(void)DEMO;
-(id)init:(int)address;
-(id)initWithArg:(NSDictionary *)dic;
-(void)pwrONOFF:(int)onOff;
-(double)getCurrByChannel:(int)ch;
-(double)getVoltByChannel:(int)ch;
-(void)setChannel:(int)ch voltage:(float)V ampere:(float)I;
-(void)pwr_ONOFF:(int)onOff_pwr OCP_ONOFF:(int)onOff_OCP;
-(double)queryByCommand:(NSString *)cmd;
-(void)close;
@end
