//
//  VegasRelay.h
//  autoTest
//
//  Created by may on 10/19/16.
//  Copyright © 2016 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/UART.h>
#import <IACFactoryFramework/Equipments.h>
#define TIMEOUT_KEYWORD @"command query error"
@interface VegasRelay : Equipments
{
    UART *uart;
    BOOL isReady;
    NSString *PathKeyWord ;

}
@property(readonly)BOOL isReady;
@property(readonly)NSString *PathKeyWord;

-(BOOL)checkUARTOpening;
-(NSString *)findPathWithKeyWord;
-(id)init:(NSString *)path speed:(int)br flowCtrl:(BOOL)flow parityCtrl:(BOOL)paryity;
-(void)open:(NSString *)path speed:(int)br flowCtrl:(BOOL)flow parityCtrl:(BOOL)paryity;
-(id)initWithArg:(NSDictionary *)dic;
-(BOOL)writeToDevice:(NSString *)uartCmd;
-(NSString *)readFromDevice;
-(void)close;
-(void)DEMO;
-(NSArray *)scanUART;
-(BOOL)writeToDeviceByBytes:(uint8_t *)buffer length:(int)len;
-(NSData *)readFromDeviceByBytes:(int)len;
-(NSString*)queryByCmd:(NSString *)cmd strWaited:(NSString*)symbol retry:(int)times timeout:(int)sec;
-(NSString*)queryRawDataByCmd:(NSString *)cmd strWaited:(NSString*)symbol retry:(int)times timeout:(int)sec;

@end
