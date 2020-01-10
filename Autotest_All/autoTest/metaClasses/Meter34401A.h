//
//  Meter34401A.h
//  autoTest
//
//  Created by TOM on 13/5/9.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Equipments.h"
#import "GPIB.h"

@interface Meter34401A : Equipments
{
    GPIB *gpib;
    BOOL isReady;
}
@property(readonly)BOOL isReady;

-(id)init:(int)address;
-(id)initWithArg:(NSDictionary *)dic;
-(double)getResistance;
-(double)getVoltageDC;
-(double)getCurrentDC;
-(double)getFrequence;
-(double)getCurrentDC_LL;
-(double)getCurrentDC_MAX;
-(double)getRES_MAX;
-(double)queryByCommand:(NSString *)cmd;
-(BOOL)isQueryTimeOut;
-(double)getDiodeChecking;
-(void)close;
-(void)DEMO;

-(void)IBCLR;

@end
