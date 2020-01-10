//
//  ValidatorPW.h
//  autoTest
//
//  Created by May on 11/30/15.
//  Copyright (c) 2015 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/PlistIO.h>

@interface ValidatorPW : NSObject
{
    BOOL isChange;
    NSRunLoop *runLoop;
    NSMutableArray *passString;
}

-(BOOL)checkPasswordMsg:(NSString *)msg checkPassword:(NSString*)password changeBGcolor:(BOOL)isBGChange;
-(NSString *)CheckSNMessage:(NSString *)msg SN_lenToCheck:(const int)snLen;
-(NSString *)CheckUserMessage:(NSString *)msg;
@end
