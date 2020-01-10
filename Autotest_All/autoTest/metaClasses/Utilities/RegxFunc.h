//
//  RegxFunc.h
//  createI2Cplist
//
//  Created by May on 13/8/6.
//  Copyright (c) 2013年 May. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegxFunc : NSObject

+(void)DEMO;
+(NSMutableArray*)regxByText:(NSString*)content textRegx:(NSString*)regx;
+(NSMutableArray*)regxByGroup:(NSString*)content groupRegx:(NSString*)regx;
+(Boolean)isMatchByRegx:(NSString*)content validRegx:(NSString*)regx;
+(NSString*)replaceByRegx:(NSString*)content replaceStr:(NSString*)str validRegx:(NSString*)regx;
@end
