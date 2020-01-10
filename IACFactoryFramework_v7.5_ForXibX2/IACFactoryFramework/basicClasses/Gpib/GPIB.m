//
//  GPIB.m
//  gpib
//
//  Created by TOM on 13/4/12.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "GPIB.h"
#include <NI4882/NI4882.h>

#pragma weak ibdev
extern int NI488CC ibdev(int boardID, int pad, int sad, int tmo, int eot, int eos);
#pragma weak Ibsta
extern unsigned int NI488CC Ibsta(void);
#pragma weak ibclr
extern unsigned int NI488CC ibclr(int ud);
#pragma weak ibonl
extern unsigned int NI488CC ibonl(int ud, int v);
#pragma weak ibrd
extern unsigned int NI488CC ibrd(int ud, void * buf, size_t cnt);
#pragma weak ibwrt
extern unsigned int NI488CC ibwrt(int ud, const void * buf, size_t cnt);

@implementation GPIB
@synthesize isGPIBopening;
@synthesize isTimeout;

-(void)openGPIB:(int)PrimaryAddress
{
    isGPIBopening=FALSE;
    
    if (ibdev)
    {
        ibdev(0,0,0,0,0,0);
    }
    else
    {
        NSRunAlertPanel(@"error", @"gpib error", @"ok", nil, nil);
        exit(1);
    }

    deviceID=ibdev(BoardIndex, PrimaryAddress, SecondaryAddress, Timeout, EotMode, EosMode);
    if (Ibsta() & ERR)
        NSLog(@"GPIB init Error (is connected to ?)");
    else
    {        
        ibclr(deviceID);
        if (Ibsta() & ERR)
            NSLog(@"clean Error");
        
        if([self writeToGPIB:@"*IDN?"])
        {
            NSLog(@"%@",[self readFromGPIBreturnStr]);
            isGPIBopening=TRUE;
            NSLog(@"GPIB open!");
        }
    }
}

-(BOOL)writeToGPIB:(NSString*)SCPIcmd
{
    const char *cmd =[SCPIcmd cStringUsingEncoding:NSASCIIStringEncoding];
    ibwrt(deviceID, (char*)cmd, strlen(cmd));
    if (Ibsta() & ERR)
    {
        NSLog(@"GPIB write Error");
        return FALSE;
    }
    return  TRUE;
}

-(double)readFromGPIB
{
    isTimeout=FALSE;
    char buffer[GPIB_bufferSize];
    ibrd(deviceID, buffer, GPIB_bufferSize);
    if (Ibsta() & ERR)
    {
        NSLog(@"GPIB read Error");
        isTimeout=TRUE;
        return -1;
    }
    else 
        return atof(buffer);
}

-(NSString*)readFromGPIBreturnStr
{
    char buffer[GPIB_bufferSize];
    ibrd(deviceID, buffer, GPIB_bufferSize);
    NSString *str=[NSString stringWithFormat:@"%s",buffer];
    return str;
}

-(void)cleanGpibError
{
    char *cmd="SYSTem:ERRor?";
    while(!ibwrt(deviceID, cmd, strlen(cmd)))
        if ([[self readFromGPIBreturnStr ] rangeOfString:@"No error"].location!=NSNotFound)
            break;
}

-(void)IBCLR
{
    ibclr(deviceID);
}

-(void)closeGPIB
{
    [self cleanGpibError];
    ibonl(deviceID, 0);//Take the device offline
    if (Ibsta() & ERR)
        NSLog(@"GPIB ibonl Error");
}
@end
