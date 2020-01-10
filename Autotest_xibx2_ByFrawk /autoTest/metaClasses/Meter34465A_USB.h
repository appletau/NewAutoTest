//
//  Meter34465A_USB.h
//  autoTest
//
//  Created by Wang Sky on 6/2/16.
//  Copyright © 2016 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/Equipments.h>
#import <IACFactoryFramework/VisaUSB.h>

@interface Meter34465A_USB : Equipments

{
    BOOL isReady;
    VisaUSB *visaUSB;
}
@property(readonly)BOOL isReady;

-(void)DEMO;
-(id)initWithArg:(NSDictionary *)dic;

-(void)closeUSB;
-(double)getResistance;
-(double)getVoltageDC;
-(double)getCurrentDC;

-(double)getFrequence;
-(double)getCurrentDC_LL;
-(double)getCurrentDC_MAX;
-(double)getRES_MAX;
-(double)getDiodeChecking;

@end
