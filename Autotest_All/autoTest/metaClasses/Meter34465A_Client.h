//
//  Meter34465A_Client.h
//  autoTest
//
//  Created by Wang Sky on 5/30/16.
//  Copyright © 2016 TOM. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Equipments.h"
#import "IAC_Socket.h"

@interface Meter34465A_Client : Equipments
{
    IAC_Socket *socketClient;
    NSString *address;
    NSMutableData *read_data;
    int port;
    long int sendDataLen;
    bool isCommunication;
    bool isSelected; 
    bool isReady ;
    bool isAction ;
}
@property bool isAction;
@property bool isReady;
@property bool isSelected;
@property bool isCommunication;

-(void)DEMO;
-(id)initWithArg:(NSDictionary *)dic;
-(bool)startClient ;
-(NSString *)getClientIP;
-(NSData *)readInFromServer;
-(BOOL)writeOutToServer:(NSData *)data;
-(double)queryByCommand:(NSString *)cmd timeout:(int)sec;
-(void)clearDataAndStr;
-(void)closeClient;


-(double)getResistance;
-(double)getVoltageDC;
-(double)getCurrentDC;

-(double)getFrequence;
-(double)getCurrentDC_LL;
-(double)getCurrentDC_MAX;
-(double)getRES_MAX;
-(double)getDiodeChecking;


@end
