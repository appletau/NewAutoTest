//
//  Eload_PEL_3021_USB.h
//  autoTest
//
//  Created by ANG on 2018/1/9.
//  Copyright © 2018年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/Equipments.h>
#import <IACFactoryFramework/VisaUSB.h>

@interface Eload_PEL_3021_USB : Equipments
{
    BOOL isReady;
    VisaUSB *visaUSB;
}
@property(readonly)BOOL isReady;

-(id)initWithArg:(NSDictionary *)dic;
-(NSString*)eloadInitial;
-(double)measureVoltage;
-(double)measureCurrent;
-(double)measurePower;
-(void)closeUSB;
-(void)DEMO;
-(NSString*)eloadTestForDemo;

@end
