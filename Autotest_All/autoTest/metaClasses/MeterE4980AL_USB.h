//
//  MeterE4980AL_USB.h
//  autoTest
//
//  Created by ANG on 2017/4/18.
//  Copyright © 2017年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Equipments.h"
#import "VisaUSB.h"

@interface MeterE4980AL_USB : Equipments
{
    BOOL isReady;
    VisaUSB *visaUSB;
}
@property(readonly)BOOL isReady;

-(id)initWithArg:(NSDictionary *)dic;

-(void)closeUSB;
//读电阻
-(double)getResistance;
//读并联电感
-(double)getInductanceP;
//读串联电感
-(double)getInductanceS;
//读并联电容
-(double)getCapacitanceP;
//读串联电感电容
-(double)getCapacitanceS;
@end
