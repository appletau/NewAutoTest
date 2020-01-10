//
//  Socket_Client.m
//  Socket
//
//  Created by May on 14/5/5.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import "UDP_Client.h"
#define SENDLENGTH 120000
#define READLENGTH 128000
#define DELAYSTREAM 10000 // 10ms

@implementation UDP_Client
@synthesize isReady, isSelected;
@synthesize isAction;

-(void)DEMO
{
    if (!isReady)
    {
        [self startClient];  // connect to server after open server
        usleep(500000);
    }
    [self writeOutToServer:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
    NSString * clientStr = [[NSString alloc] initWithData:[self readInFromServer] encoding:NSUTF8StringEncoding];
    NSLog(@"client read = %@",clientStr);
    [clientStr release];
}

-(id)init:(NSString *)addrIP withPORT:(int)Port connectWhileInit:(bool)isConnect
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(readStream:)
                                                     name:NOTIFICATION_SOCKET_CLIENT_READ
                                                   object:nil];
        
        if ([addrIP length] > 0 && Port != 0)
        {
            address = addrIP;
            port = Port ;
            sendDataLen = 0 ;
            readDataLen = 0 ;
            isAction=NO;
            isSelected = YES;
            read_data = [[NSMutableData alloc] init];
            socketClient = [[IAC_Socket alloc] init];
            if (isConnect)
                isReady = [socketClient UDP_SetupClient:addrIP withPORT:Port] ;
        }
    }
    return self ;
}

-(void)dealloc
{
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
        isReady = [socketClient UDP_SetupClient:address withPORT:port] ;
    
    return isReady;
}

-(void)readStream:(NSNotification *) aNotification
{
    if (isSelected)
    {
        uint8_t buffer[READLENGTH];
        memset(buffer,0,sizeof(buffer));
        
        NSData *data = (NSData *)[aNotification object];
        if ([data length] > 0)
        {
            readDataLen += [data length] ;
            [read_data appendData:data];
            NSLog(@"UDP_C. read len %ld",readDataLen);
            isAction = YES;
        }
    }
}

-(NSData*)readInFromServer
{
    NSData *data = [NSData dataWithData:read_data];
    [read_data setData:[NSData dataWithBytes:NULL length:0]];
    readDataLen = 0;
    return data;
}

-(void)writeOutToServer:(NSData *)data
{
    long int len = [data length];
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
        [socketClient UDP_SendData:subData];
        usleep(DELAYSTREAM);  //delay stream = 10ms
    }
    sendDataLen=0;
}

-(void)clearDataAndStr
{
    readDataLen = 0;
    sendDataLen = 0;
    [read_data setData:[NSData dataWithBytes:NULL length:0]];
}

-(void)closeClient
{
    [self clearDataAndStr];
    [socketClient UDP_CloseSocket];
    isAction = NO;
    isReady = NO ;
}

-(NSString *)getClientIP
{
    return [socketClient getIpAddress];
}
@end


