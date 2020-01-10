//
//  UART.m
//  UART
//
//  Created by TOM on 13/4/15.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "UART.h"

@implementation UART
@synthesize isUartOpening;

-(void)openComPort:(NSString *)devicePath baudRate:(int)br flowCtrl:(BOOL)isEnable parityCtrl:(BOOL)isEven
{
    isUartOpening=FALSE;
    
    int dievicPathIndex=[self isUartConnected:devicePath];
    if (dievicPathIndex!=-1)
    {
        port = [[AMSerialPortList sharedPortList] serialPortForPath:devicePath];
        port.readDelegate = self;
        
        if ([port open])
        {
            if(br==150000 || br==1250000)
            {
                if(![port setSpeed:br isAllowNonStandardBR:YES])
                    return;
            }
            else if(![port setSpeed:br isAllowNonStandardBR:NO]) return;
            
            if (isEven) [port setParity:kAMSerialParityEven];//for [] cmd request
            else        [port setParity:kAMSerialParityNone];
            
            [port setDataBits:8];
            [port setStopBits:kAMSerialStopBitsOne];
            
            if (isEnable)
            {
                [port setRTSInputFlowControl:YES];
                [port setDTRInputFlowControl:YES];
                
                [port setCTSOutputFlowControl:YES];
                [port setDSROutputFlowControl:YES];
                [port setCAROutputFlowControl:YES];
            }
            
            [port commitChanges];//this is not necessary for nonstand baudrate
            NSLog(@"info:%@",[port options]);
            
            isUartOpening=TRUE;
            
            NSLog(@"UART open!");
        }
        else
            NSLog(@"UART is not ready!");
    }
    else
        NSLog(@"UART is not connected!");
}

-(void)dealloc
{
    [dataSource release];
    [super dealloc];
}

-(int)isUartConnected:(NSString *)devicePath
{
    int index=0;
    for (AMSerialPort* temp in [[AMSerialPortList sharedPortList] serialPorts])
    {
		if([[temp bsdPath] rangeOfString:devicePath].location!=NSNotFound)
            return index;
        index++;
    }
    return -1;
}

-(NSMutableArray *)uartList
{
    dataSource=[[NSMutableArray alloc]init];
    for (AMSerialPort* temp in [[AMSerialPortList sharedPortList] serialPorts])
        [dataSource addObject:[temp bsdPath]];
    return dataSource;
}

-(BOOL)TX:(NSString *)cmd
{
    NSError *error = nil;
    
    if (port==nil) {
        NSLog(@"TX:port==nil");
        return FALSE;
    }
    
    @try {
        if(![port writeString:cmd usingEncoding:NSUTF8StringEncoding error:&error])
        {
            NSLog(@"write to uart Error!");
            if (error) 
                NSLog(@"error = %@", [error description]);
            return FALSE;
        }
        return TRUE;
    } @catch (NSException *exception) {

            NSLog(@"exception = %@", [exception description]);
            return FALSE;
    }
}

-(NSString *)RX
{
    NSError *error = nil;
    
    if (port==nil) {
        NSLog(@"RX:port==nil");
        return @"";
    }
    
    NSString *responseStr;
    
    @try {

        responseStr=[port readStringUsingEncoding:NSASCIIStringEncoding error:&error];
        
    } @catch (NSException *exception) {
        
        NSLog(@"exception = %@", [exception description]);
        responseStr = @"";
        
    } @finally {
        return responseStr;
    }
}

-(BOOL)TXbyBytes:(uint8_t *)bufer length:(int)len
{
    if (port==nil) {
         NSLog(@"TXbyBytes:port==nil");
         return FALSE;
    }
    
    
    if(![port writeBytes:bufer length:len error:NULL])
    {
        NSLog(@"write bytes to uart Error!");
        return FALSE;
    }
    return TRUE;
}

-(NSData *)RXbyBytes:(int)len
{
    if (port==nil) {
        NSLog(@"RXbyBytes:port==nil");
        return [NSData dataWithBytes:0 length:1];
    }
    
    NSData * responseData=[port readBytes:len error:NULL];
    return responseData;
}

- (void)serialPort:(AMSerialPort *)sendPort didReadData:(NSData *)data
{
    if ([data length] > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UART_READ" object:data];
        [sendPort readDataInBackground];// continue listening
    }
}

-(void) closeComPort
{
    if(port!=nil)
    {
        [port close];
        isUartOpening=FALSE;
        port.readDelegate=nil;
        port=nil;
    }
}
@end
