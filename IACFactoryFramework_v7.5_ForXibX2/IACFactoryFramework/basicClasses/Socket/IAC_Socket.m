//
//  socket_protocol.m
//  Socket_Utility
//
//  Created by May on 3/17/16.
//  Copyright © 2016 May. All rights reserved.
//

#import "IAC_Socket.h"

#define SOCKET_INVALID (~0)
#define SOCKET_ERROR -1
#define MAXCONNECTIONS 5
#define READ_SPEED 1024

@implementation IAC_Socket
@synthesize isConnect;

-(id)init
{
    if (self = [super init])
    {
        isConnect=FALSE;
        isTCP_protocol=FALSE;
        TCP_recvData = [[NSMutableData alloc] initWithData:[NSData dataWithBytes:nil length:0]];
        UDP_recvData = [[NSMutableData alloc] initWithData:[NSData dataWithBytes:nil length:0]];
    }
    return self;
}

-(void)dealloc
{
    [TCP_recvData release];
    [UDP_recvData release];
    [super dealloc];
}

#pragma mark TCP

-(BOOL)TCP_SetupServer:(int)port
{
    [self TCP_CloseSocket];
    
    socket_handler = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    if (socket_handler == SOCKET_INVALID)
    {
        NSLog(@"socket() failed");
        return FALSE;
    }
    
    memset(&address, 0, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = htonl(INADDR_ANY);
    
    int address_reuse = 1;
    if (setsockopt(socket_handler, SOL_SOCKET, SO_REUSEADDR, &address_reuse, sizeof(address_reuse)) < 0)
    {
        NSLog(@"Error setsockopt failed");
        return FALSE;
    }
    
    if (bind(socket_handler, (struct sockaddr *)&address, sizeof(address)) == SOCKET_ERROR)
    {
        [self TCP_CloseSocket];
        NSLog(@"bind() failed");
        return FALSE;
    }
    
    if (listen(socket_handler, MAXCONNECTIONS) == SOCKET_ERROR)
    {
        NSLog(@"listen() failed");
        return FALSE;
    }
    NSLog(@"socket_handler=%d",socket_handler);
    
    [self performSelectorInBackground:@selector(TCP_ServerAccept) withObject:nil];
    
    isServer=TRUE;
    isTCP_protocol=TRUE;
    return TRUE;
}

-(void)TCP_ServerAccept
{
    struct sockaddr_in client_addr;
    socklen_t fromlen = sizeof(client_addr);
    
    socket_handler = accept(socket_handler, (struct sockaddr *)&client_addr, &fromlen);
    if (socket_handler == SOCKET_ERROR)
    {
        [self TCP_CloseSocket];
        NSLog(@"Server accept failed");

        return;
    }

    [self performSelectorInBackground:@selector(readBySocket) withObject:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SOCKET_CONNECTSTART object:nil];
    isConnect=TRUE;
    
    NSLog(@"Server accept OK");
}

-(BOOL)TCP_SetupClient:(NSString*)ip withPORT:(int)port
{
    [self TCP_CloseSocket];
    
    socket_handler = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    if (socket_handler == SOCKET_INVALID)
    {
        NSLog(@"socket() failed");
        return FALSE;
    }
    
    memset(&address, 0, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = inet_addr([ip UTF8String]);
    
    if(connect(socket_handler, (struct sockaddr *)&address, sizeof(address)) == SOCKET_ERROR)
    {
        NSLog(@"Client connect %@ failed",ip);
        [self TCP_CloseSocket];
        
        return FALSE;
    }
    
    NSLog(@"Client connect OK");
    [self performSelectorInBackground:@selector(readBySocket) withObject:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SOCKET_CONNECTSTART object:nil];
    
    isTCP_protocol=TRUE;
    isConnect=TRUE;
    return TRUE;
}

-(BOOL)TCP_SendData:(NSData *)data
{
    long sendLen = send(socket_handler, [data bytes], [data length], 0);
    if (sendLen < 0)
    {
        NSLog(@"send() failed");
        return FALSE;
    }
    return TRUE;
}

-(NSData *)TCP_ReadData
{
    NSData *data = [NSData dataWithData:TCP_recvData];
    [TCP_recvData setData:[NSData dataWithBytes:nil length:0]];
    return data;
}

-(void)TCP_CloseSocket
{
    shutdown(socket_handler, SHUT_RDWR);
    usleep(50000);
    close(socket_handler);
    socket_handler=0;
    [TCP_recvData setData:[NSData dataWithBytes:nil length:0]];
    
    if (isConnect)
    {
        isConnect=FALSE;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SOCKET_CONNECTEND object:nil];
    }
}


#pragma mark UDP

-(BOOL)UDP_SetupServer:(int)port
{
    [self UDP_CloseSocket];

    socket_handler = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    
    memset(&address, 0, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_ANY);
    address.sin_port = htons(port);
    
    int address_reuse = 1;
    if (setsockopt(socket_handler, SOL_SOCKET, SO_REUSEADDR, &address_reuse, sizeof(address_reuse)) < 0)
    {
        NSLog(@"Error setsockopt failed");
        return FALSE;
    }
    
    if (bind(socket_handler, (struct sockaddr *)&address, sizeof(address)) == SOCKET_INVALID)
    {
        NSLog(@"Error bind failed");
        [self UDP_CloseSocket];
        return FALSE;
    }
    
    [self performSelectorInBackground:@selector(readBySocket) withObject:nil];
    NSLog(@"Server bind OK");
    
    isConnect=TRUE;
    isServer=TRUE;
    return TRUE;
}


-(BOOL)UDP_SetupClient:(NSString *)addrIP withPORT:(int)port
{
    [self UDP_CloseSocket];
    
    // create an internet , datagram, socket using UDP
    socket_handler = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (socket_handler == SOCKET_INVALID)
    {
        NSLog(@"Error createing socket");
        isConnect=FALSE;
        return FALSE;
    }
    
    // zero out socket address
    memset(&address,0,sizeof(address));
    address.sin_len = sizeof(address);
    
    //the address is ipv4
    address.sin_family = AF_INET;
    
    // ipv4 address is a uint32_t, convert a tring representation of the octets to the appropriate value
    address.sin_addr.s_addr = inet_addr([addrIP UTF8String]);
    // sockets are sunsigned shorts, htons(x) ensures x is in network byte order, set the port
    address.sin_port = htons(port);
    
    [self performSelectorInBackground:@selector(readBySocket) withObject:nil];
    
    isConnect=TRUE;
    return TRUE;
}

-(BOOL)UDP_SendData:(NSData *)data
{
    //sendto
    int bytes_sent = (int)sendto(socket_handler, [data bytes], [data length], 0, (struct sockaddr *)&address, sizeof(address));
    
    if (bytes_sent < 0)
    {
        NSLog(@"Error sending packet : %s",strerror(errno));
        return FALSE;
    }
    return TRUE;
    
}

-(NSData *)UDP_ReadData
{
    NSData *data = [NSData dataWithData:UDP_recvData];
    [UDP_recvData setData:[NSData dataWithBytes:nil length:0]];
    return data;
}

-(void)UDP_CloseSocket
{
    shutdown(socket_handler, SHUT_RDWR);
    usleep(50000);
    close(socket_handler);
    socket_handler=0;
    [UDP_recvData setData:[NSData dataWithBytes:nil length:0]];
    
    if (isConnect)
    {
        isConnect=FALSE;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SOCKET_CONNECTEND object:nil];
    }
}

#pragma mark common

-(void)readBySocket
{
    char buffer[READ_SPEED] = {0};
    ssize_t recsize ;
    socklen_t fromlen = sizeof(address);
    
    while (1)
    {
        //NSLog(@"socket client IP:%s PORT:%d",inet_ntoa(address.sin_addr),ntohs(address.sin_port));
        recsize = recvfrom(socket_handler, (void*)buffer, sizeof(buffer), 0, (struct sockaddr *)&address, &fromlen);
        if (recsize <=0)
        {
            NSLog(@"Error: %s",strerror(errno));
            
            if (isTCP_protocol)
                [self TCP_CloseSocket];
            else
                [self UDP_CloseSocket];
            
            break;
        }
        
        NSData *data = [NSData dataWithBytes:(const void *)buffer length:sizeof(unsigned char)*recsize];
        if ([data length]>0)
        {
            if (isTCP_protocol)
                [TCP_recvData appendData:data];
            else
                [UDP_recvData appendData:data];
            
            if (isServer)
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SOCKET_SERVER_READ object:data];
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SOCKET_CLIENT_READ object:data];
        }
    }
}

-(NSString *)getIpAddress
{
    NSArray *addresses = [[NSHost currentHost] addresses];
    for (NSString *anAddress in addresses)
    {
        if (![anAddress hasPrefix:@"127"] && [[anAddress componentsSeparatedByString:@"."] count] == 4)
        {
            return anAddress;
        }
    }
    return @"127.0.0.1";
}

@end
