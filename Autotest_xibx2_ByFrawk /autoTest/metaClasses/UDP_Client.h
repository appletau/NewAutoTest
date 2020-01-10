//
//  Socket_Client.h
//  Socket
//
//  Created by May on 14/5/5.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/IAC_Socket.h>

@interface UDP_Client : NSObject
{
    IAC_Socket *socketClient;
    NSString *address;
    NSMutableData *read_data;
    int port;
    long int readDataLen;
    long int sendDataLen;
    bool isSelected;
    bool isReady ;
    bool isAction ;
}
@property bool isAction;
@property bool isReady;
@property bool isSelected;

-(void)DEMO;
-(id)initWithArg:(NSDictionary *)dic;
-(bool)startClient ;
-(NSString *)getClientIP;
-(NSData *)readInFromServer;
-(void)writeOutToServer:(NSData *)data;
-(void)clearDataAndStr;
-(void)closeClient;

@end
