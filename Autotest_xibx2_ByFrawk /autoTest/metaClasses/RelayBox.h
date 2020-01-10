//
//  RelayBox.h
//  autoTest
//
//  Created by May on 5/15/13.
//  Copyright (c) 2013 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/UART.h>
#import <IACFactoryFramework/Equipments.h>
#import "Utility.h"

@interface RelayBox : Equipments
{
    UART *uart;
    Boolean isReady;
    Boolean isQueryTimeOut;
    int startSec;
    NSMutableString *PathKeyWord ;

}
@property(readonly)Boolean isReady;
@property(readonly)NSMutableString *PathKeyWord ;

-(void)open:(NSString *)path speed:(int)br flowCtrl:(BOOL)flow parityCtrl:(BOOL)paryity;
-(id)init:(NSString *)path speed:(int)br flowCtrl:(BOOL)flow parityCtrl:(BOOL)paryity;
-(id)initWithArg:(NSDictionary *)dic;
-(NSArray *)scanUART;
-(BOOL)cleanNoise;
-(BOOL)writeToComPort:(NSString *)uartCmd;
-(BOOL)readFromComPort;
-(int)getCurSec;
-(BOOL)checkIsTimeOut;
-(BOOL)queryByCommand:(NSString *)cmd;
-(NSString*)queryByCmd:(NSString *)cmd;
-(void)close;
-(void)DEMO;

// STM8 GEN
-(void)DEMO_GEN;
-(int)ADC:(int)ch;
-(BOOL)relayON:(int)ch;
-(BOOL)relayOFF:(int)ch;
-(BOOL)relayON;
-(BOOL)relayOFF;

// STM8 FCT
-(void)DEMO_FCT;
-(BOOL)relayON_TenByCh:(int)ch;
-(BOOL)relayON_11ByCh:(int)ch;
-(BOOL)relayON_12ByCh:(int)ch;
-(BOOL)relayON_13ByCh:(int)ch;
-(BOOL)relayON_14ByCh:(int)ch;
-(BOOL)relayOFFByChannel:(int)ch;
-(BOOL)relayOFF_FirstTen;
-(BOOL)relayOFF_First11;
-(BOOL)relayOFF_First12;
-(BOOL)relayOFF_First13;
-(BOOL)relayOFF_First14;
-(BOOL)relayAll_OFF;
@end
