//
//  GetDFUFlag.h
//  autoTest
//
//  Created by May on 13/7/1.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Equipments.h"
#import "IOReg.h"

@interface DFU : Equipments
{
    IOReg *IOdfu;
    BOOL isReady;
    BOOL isAdded;
    BOOL isRomoved;
}
@property(readonly) BOOL isReady;
@property(readonly) BOOL isAdded;
@property(readonly) BOOL isRomoved;

-(id)init:(int)ProductID productName:(NSString *)ProductString;
-(id)initWithArg:(NSDictionary *)dic;
-(void)cleanFlags;
-(void)setAddedFlag;
-(void)setRomovedFlag;
-(void)DEMO;
@end
