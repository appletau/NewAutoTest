//
//  Stream.h
//  autoTest
//
//  Created by may on 26/05/2017.
//  Copyright © 2017 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/Equipments.h>
#import "Utility.h"

@interface Stream :Equipments <NSStreamDelegate>
{
    BOOL isReady;
    NSMutableData *readBytes;
    NSMutableString *readStr;
    NSStream *iStream;
    NSStream *oStream;
    NSRunLoop *usedLoop;
}
@property(readonly)BOOL isReady;
-(id)initWithArg:(NSDictionary *)dic;
-(void)DEMO;
-(BOOL)open:(NSString *)path timeout:(int)sec;
-(void)close;
-(NSString*)read;
-(BOOL)write:(NSString*)mesg;
-(NSData*)readBytes;
-(BOOL)writeBytes:(NSData*)data;
-(NSString*)queryRawDataByCmd:(NSString *)cmd strWaited:(NSString*)symbol retry:(int)times timeout:(int)sec;
-(uint8_t)getOneByte;
@end
