//
//  GPIB.h
//  gpib
//
//  Created by TOM on 13/4/12.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BoardIndex 0
#define SecondaryAddress 0
#define Timeout T3s
#define EotMode 1
#define EosMode 0
#define GPIB_bufferSize 256

@interface GPIB : NSObject
{
    int deviceID;
    BOOL isGPIBopening;
    BOOL isTimeout;
}
@property (nonatomic, readonly) BOOL isGPIBopening;
@property (nonatomic, readonly) BOOL isTimeout;

-(void)openGPIB:(int)PrimaryAddress;
-(void)closeGPIB;
-(BOOL)writeToGPIB:(NSString *)SCPIcmd;
-(double)readFromGPIB;
-(NSString*)readFromGPIBreturnStr;
-(void)cleanGpibError;
-(void)IBCLR;
@end
