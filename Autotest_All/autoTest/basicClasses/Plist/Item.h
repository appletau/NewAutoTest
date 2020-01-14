//
//  Item.h
//  propertyTest
//
//  Created by may on 09/04/2019.
//  Copyright © 2019 IAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject
{
    float MinFloatValue;
    float MaxFloatValue;
}
@property(assign) int Order;
@property(readonly) NSString *Name;
@property(atomic,readonly) NSString *Validator;
@property(atomic,readonly) NSString *Command;

@property(retain) NSString *MinStr;
@property(retain) NSString *MaxStr;
@property(readonly,assign)float MinFloatValue;
@property(readonly,assign)float MaxFloatValue;
-(void) setMin:(NSNumber *) num;
-(void) setMax:(NSNumber *) num;
-(NSString *) Min;
-(NSString *) Max;

@property(atomic,readonly) NSString *Unit;
@property(atomic,readonly) BOOL isSkip;

@property(atomic,readwrite, retain) NSString *Value_1, *Value_2, *Value_3, *Value_4;
@property(atomic,readonly, retain) NSAttributedString *Result_1, *Result_2, *Result_3, *Result_4;
@property(atomic,assign) NSTimeInterval Time_1, Time_2, Time_3, Time_4;

@property(atomic,readwrite, retain) NSString *TestValue_1, *TestValue_2, *TestValue_3, *TestValue_4;
@property(atomic,readwrite, retain) NSString *TestMessage_1, *TestMessage_2, *TestMessage_3, *TestMessage_4;
@property(atomic,assign) BOOL isPass_1, isPass_2, isPass_3, isPass_4;



-(id)init:(NSDictionary *)dic;
-(void)setResult:(NSString *)resultStr displayStr:(NSString *)displayStr valueStr:(NSString *)valueStr item:(Item*)item dutNum:(int)dutNum;
-(void)print:(int)dutNum;
@end

/*
 below variable must be setted when a test is finised in IAC_Function
 Value_# is used to display test message on a table
 Result_# is used to display PASS / FAIL /SKIP on a table (must be setted by setColorResult() method)
 TestValue_# is used to InstantPudding for upload a real number (Pass:0 Fail:1)
 TestMessage_# is used to InstantPudding for upload a debug message
 
 Note: 1. # symbol is meaning DUT Number
       2. TestValue, TestMessage, isPass is automatic setting by setColorResult() method
 */
