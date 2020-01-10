//
//  Meter34465A_Client.m
//  autoTest
//
//  Created by Wang Sky on 5/30/16.
//  Copyright © 2016 TOM. All rights reserved.
//

#import "Meter34465A_Client.h"

#define SENDLENGTH 120000
#define READLENGTH 128000
#define DELAYSTREAM 10000 // 10ms

@implementation Meter34465A_Client
@synthesize isReady, isCommunication, isSelected;
@synthesize isAction;

-(void)DEMO
{
    if (!isReady)
    {
        [self startClient];  // connect to server after open server
        usleep(500000);
    }
    NSLog(@"(Socket)DMM query current = %f",[self queryByCommand:@"MEASure:CURRent:DC?" timeout:3]);
    NSLog(@"(Socket)DMM volt = %f",[self getVoltageDC]);
    NSLog(@"(Socket)DMM resistance = %f",[self getResistance]);
    [self closeClient];
}

-(id)init:(NSString *)addrIP withPORT:(int)Port connectWhileInit:(bool)isConnect
{
    if (self = [super init])
    {
        //        [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                 selector:@selector(readStream:)
        //                                                     name:NOTIFICATION_SOCKET_CLIENT_READ
        //                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectStart)
                                                     name:NOTIFICATION_SOCKET_CONNECTSTART
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectEnd)
                                                     name:NOTIFICATION_SOCKET_CONNECTEND
                                                   object:nil];
        if ([addrIP length] > 0 && Port != 0)
        {
            address = addrIP;
            port = Port ;
            sendDataLen = 0 ;
            isAction=NO;
            isSelected = YES;
            isCommunication = NO;
            read_data = [[NSMutableData alloc] init];
            socketClient = [[IAC_Socket alloc] init];
            if (isConnect)
            {
                if(isReady)
                    [self closeClient];
                isReady = [socketClient TCP_SetupClient:addrIP withPORT:Port] ;
            }
        }
    }
    return self ;
}

-(void)dealloc
{
    [self closeClient];
    [read_data release];
    [socketClient release];
    [super dealloc];
}

-(id)initWithArg:(NSDictionary *)dic
{
    id tmp = nil;
    NSString *controltype = [dic objectForKey:@"CTL_TYPE"];
    if([controltype isEqualToString:@"Client"])
        tmp = [self init: [dic objectForKey:@"IPAddress"] withPORT:[[dic objectForKey:@"Port"] intValue] connectWhileInit:[[dic objectForKey:@"Connect"] boolValue]];
    
    return tmp;
}

-(bool)startClient
{
    if (!isReady)
    {
        isCommunication = NO ;
        isReady = [socketClient TCP_SetupClient:address withPORT:port] ;
    }
    return isReady;
}

-(void)connectStart
{
    isCommunication = YES;
}

-(void)connectEnd
{
    isCommunication = NO;
}

//-(void)readStream:(NSNotification *) aNotification
//{
//    if (!isSelected) return;
//
//    NSData *data = [aNotification object];
//    if ([data length] > 0)
//    {
//        readDataLen += [data length] ;
//        [read_data appendData:data];
//        NSLog(@"S. read len %ld",readDataLen);
//        isAction = YES;
//    }
//}
-(NSData*)readInFromServer
{
    NSData *data = [socketClient TCP_ReadData];
    return data;
}

-(BOOL)writeOutToServer:(NSData *)data
{
    long int len = [data length];
    BOOL wState = FALSE;
    for (long int i = 0; i < len; i+= SENDLENGTH)
    {
        NSRange rang = NSMakeRange(i, SENDLENGTH);
        if (i+SENDLENGTH > len)
        {
            rang = NSMakeRange(i, len-i);
        }
        NSData * subData = [data subdataWithRange:rang];
        sendDataLen += [subData length];
        NSLog(@"send len %ld",sendDataLen);
        wState = [socketClient TCP_SendData:subData];
        usleep(DELAYSTREAM);  //delay stream = 10ms
    }
    sendDataLen=0;
    return wState;
}

-(void)clearDataAndStr
{
    sendDataLen = 0;
    [read_data setData:[NSData dataWithBytes:nil length:0]];
}

-(void)closeClient
{
    [self clearDataAndStr];
    [socketClient TCP_CloseSocket];
    isAction = NO;
    isReady = NO ;
    NSLog(@"client is disconnect");
}

-(NSString *)getClientIP
{
    return [socketClient getIpAddress];
}

#pragma mark command use String
-(void)writeCommand:(NSString*)cmd
{
    NSData *cmdData = [[NSString stringWithFormat:@"%@\r\n",cmd] dataUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"write cmd:%@",cmd);
    [self writeOutToServer:cmdData];
}
-(double)readResponse
{
    NSData *data = [self readInFromServer];
    const char *aa = [data bytes];
    for (int i = 0 ; i < [data length] ; i++)
        NSLog(@"%d = %x",i,aa[i]);
    NSString *response = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
    NSLog(@"read response:%@",response);
    return [response doubleValue];
}

//-(double)queryByCommand:(NSString *)cmd
//{
//    [self writeCommand:cmd];
//    sleep(1);
//    return [self readResponse];
//}

-(double)queryByCommand:(NSString *)cmd timeout:(int)sec
{
    [self writeCommand:[NSString stringWithFormat:@"%@",cmd]];
    
    NSDate *over=[NSDate dateWithTimeIntervalSinceNow:sec];
    
    while(1)
    {
        usleep(5000);
        
        NSData *data = [self readInFromServer];
        
        if ([data length]>0)
        {
            NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSString *retunStr=[NSString stringWithString:response];
            NSLog(@"socket response = %@",response);
            [response release];
            
            return [retunStr doubleValue];
        }
        else
        {
            NSDate *now=[NSDate dateWithTimeIntervalSinceNow:0];
            if ([now compare:over] == NSOrderedDescending )
                break;
        }
    }
    return 0;
}

#pragma mark Meter34465A
-(double)getResistance
{
    return [self queryByCommand:@"MEASure:RESistance?" timeout:3];
}

-(double)getVoltageDC
{
    return [self queryByCommand:@"MEASure:VOLTage:DC?" timeout:3];
}

-(double)getCurrentDC
{
    return [self queryByCommand:@"MEASure:CURRent:DC?" timeout:3] ;
}

-(double)getFrequence
{
    return [self queryByCommand:@"MEASure:FREQuency?" timeout:3];
}

-(double)getCurrentDC_LL
{
    [self writeCommand:@"CONF:CURR:DC 1, DEF"];
    return [self queryByCommand:@"READ?" timeout:3];
}

-(double)getCurrentDC_MAX
{
    [self writeCommand:@"CONF:CURR:DC MAX, DEF"];
    return [self queryByCommand:@"READ?" timeout:3];
}

-(double)getRES_MAX
{
    [self  writeCommand:@"CONF:RES MAX, DEF"];
    return [self queryByCommand:@"READ?" timeout:3];
}

-(double)getDiodeChecking
{
    [self writeCommand:@"CONF:DIOD"];
    return [self queryByCommand:@"READ?" timeout:3];
}



@end
