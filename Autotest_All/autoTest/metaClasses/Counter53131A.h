//
//  Counter53131A.h
//  autoTest
//
//  Created by May on 5/16/13.
//  Copyright (c) 2013 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Equipments.h"
#import "GPIB.h"

@interface Counter53131A : Equipments
{
    GPIB *gpib;
    BOOL isReady;
}
@property(readonly)BOOL isReady;

-(id)init:(int)address;
-(id)initWithArg:(NSDictionary *)dic;

-(double)getFrequency;
-(double)getFrequencyByArg:(NSString*)expectedVal resolution:(NSString*)resoluVal;
-(double)queryByCommand:(NSString *)cmd;
-(BOOL)isQueryTimeOut;
-(void)close;
-(void)DEMO;
@end
