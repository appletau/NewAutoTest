//
//  Meter34401A.h
//  autoTest
//
//  Created by TOM on 13/5/9.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/Equipments.h>
#import <IACFactoryFramework/GPIB.h>

@interface Eload_PEL_3021 : Equipments
{
    GPIB *gpib;
    BOOL isReady;
}
@property(readonly)BOOL isReady;

-(id)init:(int)address;
-(id)initWithArg:(NSDictionary *)dic;
-(NSString*)eloadInitial;
-(double)measureVoltage;
-(double)measureCurrent;
-(double)measurePower;
-(void)IBCLR;
-(void)close;
-(void)DEMO;
-(NSString*)eloadTestForDemo;

@end
