//
//  csv.h
//  autoTest
//
//  Created by May on 19/4/18.
//  Copyright (c) 2019年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlistIO.h"

@interface CSV : NSObject
{
    PlistIO *plist;
    NSMutableString *csvPath;
}

-(void)saveOppRecord:(nonnull NSString*)sn dutNum:(int)dutNum begin:(nonnull NSString*)begin rSN:(nullable NSString *)rSN tSN:(nullable NSString *)tSN uNum:(nullable NSString*)uNum sID:(nullable NSString *)sID;
-(void)saveCycleTimeRecord:(nonnull NSString*)sn dutNum:(int)dutNum;
@end
