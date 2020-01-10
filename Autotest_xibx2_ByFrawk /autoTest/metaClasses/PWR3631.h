//
//  PowerSupply.h
//  autoTest
//
//  Created by May on 13/6/27.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/Equipments.h>
#import <IACFactoryFramework/GPIB.h>

@interface PWR3631 : Equipments
{
    GPIB *gpib;
    BOOL isReady;
}
@property(readonly)BOOL isReady;

-(void)DEMO;
-(id)init:(int)address;
-(id)initWithArg:(NSDictionary *)dic;
-(void)setP6V:(float)V ampere:(float)I;
-(void)setP25V:(float)V ampere:(float)I;
-(double)queryByCommand:(NSString *)cmd;
-(BOOL)isQueryTimeOut;
-(void)close;
@end

