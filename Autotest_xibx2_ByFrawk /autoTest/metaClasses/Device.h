//
//  Device.h
//  autoTest
//
//  Created by TOM on 13/4/16.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/UART.h>
#import <IACFactoryFramework/Equipments.h>
#import <IACFactoryFramework/ControlBits.h>
#import "RegxFunc.h"
#import "Utility.h"



@interface Device : Equipments
{
    UART *uart;
    BOOL isReady;
    uint8_t seqNumer;
    NSMutableString *PathKeyWord ;
}
@property(readonly)BOOL isReady;
@property(readonly)NSMutableString *PathKeyWord;
@property(nonatomic,assign)uint8_t seqNumer;

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
-(NSString*)queryByIOS_Cmd:(NSString *)iosCmd strWaited:(NSString*)keyWord retry:(int)times timeout:(NSTimeInterval)sec;

// control bit
-(unsigned char *)getSHA1:(unsigned char*)secretKey andNonce:(unsigned char*)nonce;
-(unsigned char *)getNonce;
-(NSString *)getRTC;
-(BOOL)setRTC;

// diags
-(BOOL)enterDiags;

//pass through
-(BOOL)enterPassThrough;
-(void)exitPassThrough;


//MCU write & read
-(NSData*)GetResponseFromMCU:(NSString*)cmd seqNumer:(uint8_t)seqNum;
-(NSString*)SendMessageToMCU:(NSString*)cmd Data:(NSString*)data seqNumer:(uint8_t)seqNum;
-(NSString*)ForAnyCmd:(NSString*)cmd Data:(NSString*)data seqNumer:(uint8_t)seqNum;
-(NSString*)SendHarnessMessageToMCU:(NSString*)data seqNumer:(uint8_t)seqNum;
-(NSString*)GetHarnessResponseFromMCU:(uint8_t)seqNum;


//Psoc write & read by diag
-(NSString*)i2cWriteByDiag:(NSString*)ch chipAddr:(NSString*)addr cmd:(uint8_t)cmd Data:(NSString*)data seqNumber:(uint8_t)seqNum;
-(NSString*)i2cReadByDiag:(NSString*)ch chipAddr:(NSString*)addr cmdSent:(uint8_t)cmdSent len:(NSString*)len seqNumber:(uint8_t)seqNum;

// save smokey logs
-(void)saveSmokeyLogBySeqName:(NSString *)SeqName;

@end
