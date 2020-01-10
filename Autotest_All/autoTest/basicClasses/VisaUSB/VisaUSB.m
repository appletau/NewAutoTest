//
//  visaUSB.m
//  autoTest
//
//  Created by Wang Sky on 6/1/16.
//  Copyright © 2016 TOM. All rights reserved.
//

#import "VisaUSB.h"
#include <VISA/visa.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#pragma weak viFindNext
extern ViStatus _VI_FUNC viFindNext(ViFindList vi, ViChar _VI_FAR desc[]);
#pragma weak viOpenDefaultRM
extern ViStatus _VI_FUNC viOpenDefaultRM(ViPSession vi);
#pragma weak viFindRsrc
extern ViStatus _VI_FUNC viFindRsrc(ViSession sesn, ViString expr, ViPFindList vi,ViPUInt32 retCnt, ViChar _VI_FAR desc[]);
#pragma weak viOpen
extern ViStatus _VI_FUNC viOpen(ViSession sesn, ViRsrc name, ViAccessMode mode,ViUInt32 timeout, ViPSession vi);
#pragma weak viWrite
extern ViStatus _VI_FUNC viWrite(ViSession vi, ViBuf  buf, ViUInt32 cnt, ViPUInt32 retCnt);
#pragma weak viRead
extern ViStatus _VI_FUNC viRead(ViSession vi, ViPBuf buf, ViUInt32 cnt, ViPUInt32 retCnt);
#pragma weak viClose
extern ViStatus _VI_FUNC viClose(ViObject vi);
#pragma weak viClear
extern ViStatus _VI_FUNC viClear(ViSession vi);
#pragma weak viReadToFile
extern ViStatus _VI_FUNC  viReadToFile(ViSession vi, ViConstString filename, ViUInt32 cnt, ViPUInt32 retCnt);

@implementation VisaUSB
@synthesize isUSBopening;

-(NSArray*)findUSBDevices
{
    
    usbDevices = [[NSMutableArray alloc]init];
    static ViUInt32 numInstrs;
    static ViFindList findList;
    static char instrDescriptor[VI_FIND_BUFLEN];
    isUSBopening = FALSE;
    if (viOpenDefaultRM)
        status = viOpenDefaultRM (&defaultRM);
    else {
        NSRunAlertPanel(@"error", @"VISA Lib Error", @"ok", nil, nil);
        exit(1);
    }
    
    if (viFindRsrc)
        viFindRsrc (defaultRM, "?*INSTR", &findList, &numInstrs, instrDescriptor);
    else {
        NSRunAlertPanel(@"error", @"VISA Lib Error", @"ok", nil, nil);
        exit(1);
    }
    
    [usbDevices addObject:[NSString stringWithFormat:@"%s",instrDescriptor]];
    while (--numInstrs)
    {
        status = viFindNext (findList, instrDescriptor);
        [usbDevices addObject:[NSString stringWithFormat:@"%s",instrDescriptor]];
    }
    if (viClose)
        viClose(defaultRM);
    else {
        NSRunAlertPanel(@"error", @"VISA Lib Error", @"ok", nil, nil);
        exit(1);
    }
    return usbDevices;
}

-(void)openUSB:(NSString*)usbName
{
    isUSBopening = FALSE;
    if (viOpenDefaultRM)
        status = viOpenDefaultRM (&defaultRM);
    else {
        NSRunAlertPanel(@"error", @"VISA Lib Error", @"ok", nil, nil);
        exit(1);
    }
    
    const char *visaName =[usbName cStringUsingEncoding:NSASCIIStringEncoding];
    if (viOpen)
        status = viOpen (defaultRM, (char*)visaName, VI_NULL, VI_NULL, &instr);
    else {
        NSRunAlertPanel(@"error", @"VISA Lib Error", @"ok", nil, nil);
        exit(1);
    }
        
    if (status < VI_SUCCESS)
    {
        NSLog(@"USB Connect FAIL:%@",usbName);
    }else {
             //[self writeToUSB:@"*CLS"];
        if (viClear)
            status = viClear(defaultRM);
        else {
            NSLog(@"VISA Lib Error");
            return ;
        }
        if (status < VI_SUCCESS)
        {
            NSLog(@"Clean Error");
        }
   
        if([self writeToUSB:@"*IDN?\n"])
        {
            isUSBopening = TRUE;
            NSLog(@"USB open!%@",[self readFromUSBreturnStr]);
            [self writeToUSB:@"SYSTem:ERRor?"];
            NSLog(@"USB open!%@",[self readFromUSBreturnStr]);
    
        }else
            NSLog(@"USB open Fail!");
    }
}

-(BOOL)writeToUSB:(NSString*)scpiCMD
{
    const char *cmd =[scpiCMD cStringUsingEncoding:NSASCIIStringEncoding];
    strcpy(stringinput,(char*)cmd);
    if(viWrite)
        status = viWrite (instr, (ViBuf)stringinput, (ViUInt32)strlen(stringinput), &writeCount);
    else {
        NSLog(@"VISA Lib Error");
        return NO;
    }
    return !status;

}

-(double)readFromUSB
{
    static unsigned char buffer[100];
    if (viRead)
        viRead (instr, buffer, 100, &retCount);
    else {
        NSLog(@"VISA Lib Error");
        return 0.0;
    }
    NSString *str=[NSString stringWithFormat:@"%s",buffer];

    return [str doubleValue];
}

-(NSString*)readFromUSBreturnStr
{
    static unsigned char buffer[100];
    if (viRead)
        viRead (instr, buffer, 100, &retCount);
    else {
        NSLog(@"VISA Lib Error");
        return @"";
    }
    NSString *str=[NSString stringWithFormat:@"%s",buffer];
    return str;
}

-(BOOL)readFromUSB_ToFile:(NSString*)fileName readByte:(int)byte
{
    viReadToFile(instr, [fileName UTF8String], byte, &retCount);
    NSLog(@"transfer bytes:%d",retCount);
    return (retCount>0)?YES:NO;
}

-(void)closeUSB
{
    [self writeToUSB:@"SYSTem:ERRor?"];
    [self readFromUSBreturnStr];
    if (viClose) {
        viClose(instr);
        viClose(defaultRM);
    }
    else {
        NSLog(@"VISA Lib Error");
        return ;
    }
}
@end
