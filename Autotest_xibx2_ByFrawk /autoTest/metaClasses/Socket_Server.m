//
//  Socket_Server.m
//  Socket
//
//  Created by May on 14/5/5.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import "Socket_Server.h"
#define SENDLENGTH 120000
#define READLENGTH 128000
#define DELAYSTREAM 10000 // 10ms

@implementation Socket_Server
@synthesize isReady, isCommunication, isSelected;
@synthesize isAction;

-(void)DEMO
{
    if (!isReady)
    {
        [self startServer];  // wait client connect after startServer
        usleep(500000);
    }
    [self writeOutToClient:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
    NSString * serverStr = [[NSString alloc] initWithData:[self readInFromClient] encoding:NSUTF8StringEncoding];
    NSLog(@"server read = %@",serverStr);
    [serverStr release];
}

-(id)init:(int) Port acceptWhileInit:(bool)isAccept
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(readStream:)
                                                     name:NOTIFICATION_SOCKET_SERVER_READ
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectStart)
                                                     name:NOTIFICATION_SOCKET_CONNECTSTART
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectEnd)
                                                     name:NOTIFICATION_SOCKET_CONNECTEND
                                                   object:nil];
        if (Port != 0)
        {
            port = Port ;
            sendDataLen = 0 ;
            readDataLen = 0 ;
            isAction = NO;
            isSelected = YES;
            isCommunication = NO;
            read_data = [[NSMutableData alloc] init];
            socketServer = [[IAC_Socket alloc] init];
            if (isAccept)
                isReady = [socketServer TCP_SetupServer:Port] ;
        }
    }
    return self ;
}

-(void)dealloc
{
    [read_data release];
    [socketServer release];
    [super dealloc];
}

-(id)initWithArg:(NSDictionary *)dic
{
	id tmp = nil;
	NSString *controltype = [dic objectForKey:@"CTL_TYPE"];
	if([controltype isEqualToString:@"Server"])
		tmp = [self init: [[dic objectForKey:@"Port"] intValue] acceptWhileInit:[[dic objectForKey:@"Accept"] boolValue]];
	
	return tmp;
}

-(bool)startServer
{
    if (!isReady)
    {
        isCommunication = NO ;
        isReady = [socketServer TCP_SetupServer:port] ;
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

-(void)readStream:(NSNotification *) aNotification
{
    if (isSelected)
    {
        NSData *data = (NSData *)[aNotification object];
        if ([data length] > 0)
        {
            readDataLen += [data length] ;
            [read_data appendData:data];
            NSLog(@"S. read len %ld",readDataLen);
            isAction = YES;
        }
    }

//    if (isSelected)
//    {
//        NSInteger bytesRead;
//        uint8_t buffer[READLENGTH];
//        memset(buffer,0,sizeof(buffer));
//        NSLog(@"%@",[[aNotification object] className]);
//        bytesRead = [(NSInputStream *)[aNotification object] read:buffer maxLength:READLENGTH];
//        if (bytesRead>0)
//        {
//            NSData *data = [NSData dataWithBytes:buffer length:bytesRead];
//            if ([data length] > 0)
//            {
//                readDataLen += [data length] ;
//                [read_data appendData:data];
//                NSLog(@"S. read len %ld",readDataLen);
//                isAction = YES;
//            }
//        }
//    }
}

-(NSData*)readInFromClient
{
    NSData *data = [NSData dataWithData:read_data];
    [read_data setData:[NSData dataWithBytes:NULL length:0]];
    readDataLen = 0;
    return data;
}

-(void)writeOutToClient:(NSData *)data;
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
        [socketServer TCP_SendData:subData];
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

-(void)closeServer
{
    [self clearDataAndStr];
    [socketServer TCP_CloseSocket];
    isAction = NO;
    isReady = NO ;
}

-(NSString *)getServerIP
{
    return [socketServer getIpAddress];
}

@end
