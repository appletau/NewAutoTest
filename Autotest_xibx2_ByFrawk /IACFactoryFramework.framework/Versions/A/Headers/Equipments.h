//
//  Equipments.h
//  autoTest
//
//  Created by HenryLee on 1/3/14.
//  Copyright (c) 2014 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol equipmentProtocol
@required
-(id)initWithArg:(NSDictionary *)dic;
@end

@interface Equipments : NSObject<equipmentProtocol>
@property int myThreadIndex;
+(void)setLogFolderPath:(NSString*)path;
+(void)attachLogFileWithTitle:(NSString*)title withDate:(NSString*)date
                  withMessage:(NSString*)content forThread:(int)num;
+(void)attachLogFileWithTitle:(NSString*)title withDate:(NSString*)date
                  withMessage:(NSString*)content;
+(NSString *)saveLogWithFileName:(NSString *)name forThread:(int)num;
+(NSString *)saveLogWithFileName:(NSString *)name;
+(void)clearLogFileWithThread:(int)num;
+(void)clearLogFile;
+(void)delayWithSecond:(int)sec forThread:(int)num;
+(void)delayWithSecond:(int)sec;
+(void)delayWithMicorSecond:(int)ms forThread:(int)num;
+(void)delayWithMicorSecond:(int)ms;

-(void)setLogFolderPath:(NSString*)path;
-(void)attachLogFileWithTitle:(NSString*)title withDate:(NSString*)date withMessage:(NSString*)content;
-(NSString *)saveLogWithFileName:(NSString *)name;
@end
