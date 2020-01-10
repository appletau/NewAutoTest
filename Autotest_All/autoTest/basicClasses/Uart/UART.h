//
//  UART.h
//  UART
//
//  Created by TOM on 13/4/15.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMSerial/AMSerialPort.h>
#import <AMSerial/AMSerialPortAdditions.h>
#import <AMSerial/AMSerialPortList.h>
#import <AMSerial/AMSDKCompatibility.h>

@interface UART : NSObject <AMSerialPortReadDelegate>
{
    AMSerialPort *port;
    BOOL isUartOpening;
    NSMutableArray *dataSource;
}
@property(readonly)BOOL isUartOpening;

-(void)openComPort:(NSString *)devicePath baudRate:(int)br flowCtrl:(BOOL)isEnable parityCtrl:(BOOL)isEven;
-(int)isUartConnected:(NSString *)devicePath;
-(BOOL)TX:(NSString *)uartCmd;
-(NSString *) RX;
-(BOOL)TXbyBytes:(uint8_t *)bufer length:(int)len;
-(NSData *)RXbyBytes:(int)len;
-(void)closeComPort;
-(NSMutableArray *)uartList;
@end
