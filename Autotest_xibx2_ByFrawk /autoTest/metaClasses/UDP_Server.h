//
//  Socket_Server.h
//  Socket
//
//  Created by May on 14/5/5.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/IAC_Socket.h>

@interface UDP_Server : NSObject
{
    IAC_Socket *socketServer ;
    NSMutableData *read_data;
    int port ;
    long int readDataLen;
    long int sendDataLen;
    bool isSelected;
    bool isReady ;
    bool isAction;
}
@property bool isReady;
@property bool isSelected;
@property bool isAction;

-(void)DEMO;
-(id)initWithArg:(NSDictionary *)dic;
-(bool)startServer;
-(NSData *)readInFromClient;
-(NSString *)getServerIP;
-(void)writeOutToClient:(NSData *)data;
-(void)clearDataAndStr;
-(void)closeServer ;

@end
