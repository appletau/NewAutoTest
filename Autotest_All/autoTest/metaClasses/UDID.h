//
//  UDID.h
//  tryFramework
//
//  Created by May on 14/2/24.
//  Copyright (c) 2014年 Richard Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOReg.h"
#import "Equipments.h"


@interface UDID : Equipments
{
    IOReg *IOudid;
    BOOL isReady;
    BOOL isAdded;
    BOOL isRomoved;
    NSMutableString *devUDID;
    NSMutableString *locactionID;
}

@property(readonly) BOOL isReady;
@property(readonly) BOOL isAdded;
@property(readonly) BOOL isRomoved;
@property(readonly) NSMutableString *devUDID;
@property(readonly) NSMutableString *locactionID;

-(id)init:(int)ProductID productName:(NSString *)ProductString;
-(id)initWithArg:(NSDictionary *)dic;
-(void)cleanFlags;
-(void)setAddedFlag:(NSNotification *)_notification;
-(void)setRomovedFlag;
-(void)DEMO;
@end
