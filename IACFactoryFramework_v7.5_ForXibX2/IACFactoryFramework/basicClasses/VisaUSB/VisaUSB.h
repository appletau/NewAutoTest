//
//  visaUSB.h
//  autoTest
//
//  Created by Wang Sky on 6/1/16.
//  Copyright © 2016 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <VISA/visa.h>
@interface VisaUSB : NSObject

{
    int deviceID;
    BOOL isUSBopening;
    BOOL isTimeout;
    NSMutableArray *usbDevices;
    ViSession defaultRM;
    ViSession instr;
    ViUInt32 retCount;
    ViUInt32 writeCount;
    ViStatus status;
    char stringinput[512];
}
@property (nonatomic, readonly) BOOL isUSBopening;
-(void)openUSB:(NSString*)usbName;
-(BOOL)writeToUSB:(NSString*)scpiCMD;
-(double)readFromUSB;
-(NSString*)readFromUSBreturnStr;
-(BOOL)readFromUSB_ToFile:(NSString*)fileName readByte:(int)byte;
-(void)closeUSB;
-(NSMutableArray*)findUSBDevices;
@end
