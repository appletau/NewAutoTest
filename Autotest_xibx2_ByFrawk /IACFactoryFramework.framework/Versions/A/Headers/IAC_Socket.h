//
//  IAC_Socket.h
//  Socket_Utility
//
//  Created by May on 3/17/16.
//  Copyright © 2016 May. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define NOTIFICATION_SOCKET_CONNECTSTART @"SOCKET_ConnectStart"
#define NOTIFICATION_SOCKET_CONNECTEND   @"SOCKET_ConnectEnd"
#define NOTIFICATION_SOCKET_SERVER_READ  @"SOCKET_SERVER_READ"
#define NOTIFICATION_SOCKET_CLIENT_READ  @"SOCKET_CLIENT_READ"

@interface IAC_Socket : NSObject
{
    bool isConnect;
    bool isServer;
    bool isTCP_protocol;
    int socket_handler;
    struct sockaddr_in address;
    
    NSMutableData *TCP_recvData;
    NSMutableData *UDP_recvData;
}

@property (assign,readonly) bool isConnect;
-(BOOL)TCP_SetupServer:(int)port;
-(BOOL)TCP_SetupClient:(NSString*)ip withPORT:(int)port;
-(BOOL)TCP_SendData:(NSData *)data;
-(void)TCP_CloseSocket;
-(NSData *)TCP_ReadData;


-(BOOL)UDP_SetupServer:(int)port;
-(BOOL)UDP_SetupClient:(NSString*)ip withPORT:(int)port;
-(BOOL)UDP_SendData:(NSData *)data;
-(void)UDP_CloseSocket;
-(NSData *)UDP_ReadData;

-(NSString *)getIpAddress;

@end
