//
//  STM8.h
//  autoTest
//
//  Created by TOM on 2014/8/26.
//  Copyright (c) 2014年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UART.h"
#import "Equipments.h"
#import "Utility.h"

@interface SeggerFlasher: Equipments
{
    UART *uart;
    BOOL isReady;
    NSMutableString *PathKeyWord ;
}
@property(readonly)BOOL isReady;
@property(readonly)NSMutableString *PathKeyWord ;

-(NSArray *)scanUART;
-(void)open:(NSString *)path speed:(int)br flowCtrl:(BOOL)flow parityCtrl:(BOOL)paryity;
-(id)init:(NSString *)path speed:(int)br flowCtrl:(BOOL)flow parityCtrl:(BOOL)paryity;
-(id)initWithArg:(NSDictionary *)dic;
-(NSString*)queryByCmd:(NSString *)cmd;
-(BOOL)writeToSF:(NSString *)uartCmd;
-(NSString *)findPathWithKeyWord;
-(NSString *)readFromSF;
-(void)close;
-(void)DEMO;
@end
