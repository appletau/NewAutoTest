//
//  SC18IM700.h
//  autoTest
//
//  Created by TOM on 2014/10/7.
//  Copyright (c) 2014年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/UART.h>
#import <IACFactoryFramework/Equipments.h>

@interface SC18IM700 : Equipments
{
    UART *uart;
    BOOL isReady;
    NSMutableString *PathKeyWord ;
}
@property(readonly)BOOL isReady;
@property(readonly)NSMutableString *PathKeyWord ;

-(void)DEMO;
-(BOOL)checkUARTOpening;
-(void)open:(NSString *)path speed:(int)br flowCtrl:(BOOL)flow parityCtrl:(BOOL)paryity;
-(id)init:(NSString *)path speed:(int)br flowCtrl:(BOOL)flow parityCtrl:(BOOL)paryity;
-(id)initWithArg:(NSDictionary *)dic;
-(NSString *)findPathWithKeyWord;
-(NSArray *)scanUART;
-(void)close;

#pragma mark IIC Access
-(bool)IICwrite:(NSString*)chipAddr iicData:(NSString*)data;
-(int)IICread:(NSString*)chipAddr iicReadLen:(int)len outData:(NSMutableString*)opt;
-(int)IICwriteAndRead:(NSString*)chipAddr iicData:(NSString*)data iicReadLen:(int)len outData:(NSMutableString*)opt;

#pragma mark IIC Ignore Case Access
-(bool)IICwrite:(NSString*)chipAddr iicData:(NSString*)data ignore:(BOOL)ignoreState;
-(int)IICread:(NSString*)chipAddr iicReadLen:(int)len outData:(NSMutableString*)opt ignore:(BOOL)ignoreState;
-(int)IICwriteAndRead:(NSString*)chipAddr iicData:(NSString*)data iicReadLen:(int)len outData:(NSMutableString*)opt ignore:(BOOL)ignoreState;

#pragma mark IIC Ignore Case Access with Delay
-(bool)IICwrite:(NSString*)chipAddr iicData:(NSString*)data ignore:(BOOL)ignoreState withDelay:(int)microSeconds;;
-(int)IICread:(NSString*)chipAddr iicReadLen:(int)len outData:(NSMutableString*)opt ignore:(BOOL)ignoreState withDelay:(int)microSeconds;;
-(int)IICwriteAndRead:(NSString*)chipAddr iicData:(NSString*)data iicReadLen:(int)len outData:(NSMutableString*)opt ignore:(BOOL)ignoreState withDelay:(int)microSeconds;
#pragma mark REG Access
-(void)REGwrite:(NSString*)regAndData;
-(int)REGread:(NSString*)reg outData:(NSMutableString*)opt;
-(NSString*)bytesToStr:(NSData *)data;
@end
