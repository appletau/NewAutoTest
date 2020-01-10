//
//  Item.m
//  propertyTest
//
//  Created by may on 09/04/2019.
//  Copyright © 2019 IAC. All rights reserved.
//

#import "Item.h"

@implementation Item

-(id) init:(NSDictionary*)dic
{
    if(self=[super init])
    {
        _Name=[dic[@"name"] copy];
        _Validator=[dic[@"validator"] copy];
        _Command=[dic[@"command"] copy];
        _Min=[dic[@"min"] copy];
        _Max=[dic[@"max"] copy];
        _Unit=[dic[@"unit"] copy];
        _isSkip=[dic[@"skip"] boolValue];
        
        if(_Name==nil)_Name=@"";
        if(_Validator==nil)_Validator=@"";
        if(_Command==nil)_Command=@"";
        if(_Min==nil)_Min=@"";
        if(_Max==nil)_Max=@"";
        if(_Unit==nil)_Unit=@"";
    }
    return self;
}

-(void) dealloc
{
    [_Value_1 release];[_Value_2 release];[_Value_3 release];[_Value_4 release];
    [_Result_1 release];[_Result_2 release];[_Result_3 release];[_Result_4 release];
    [_TestValue_1 release];[_TestValue_2 release];[_TestValue_3 release];[_TestValue_4 release];
    [_TestMessage_1 release];[_TestMessage_2 release];[_TestMessage_3 release];[_TestMessage_4 release];
    [super dealloc];
}


-(void) setColorResult:(NSString *)str dutNum:(int)dutNum
{
    @synchronized(self)
    {
        if([str length]==0)
        {
            [self setValue:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"isPass_%d",dutNum]];
            [self setValue:@"" forKey:[NSString stringWithFormat:@"Result_%d",dutNum]];
            [self setValue:@"NA" forKey:[NSString stringWithFormat:@"TestValue_%d",dutNum]];
            [self setValue:@"NA" forKey:[NSString stringWithFormat:@"TestMessage_%d",dutNum]];
            return;
        }
        
        BOOL isPass=[str isEqualToString:@"FAIL"]?NO:YES;
        
        [self setValue:[NSNumber numberWithBool:isPass] forKey:[NSString stringWithFormat:@"isPass_%d",dutNum]];
        
        NSDictionary *color = @{NSForegroundColorAttributeName:[str isEqualToString:@"PASS"]?[NSColor greenColor]:([str isEqualToString:@"FAIL"]?[NSColor redColor]:[NSColor yellowColor])};

        NSAttributedString *result=[[NSAttributedString alloc] initWithString:str attributes:color];
        [self setValue:result forKey:[NSString stringWithFormat:@"Result_%d",dutNum]];
        [result release];
        
        NSString *testDisplayMesg=[self valueForKey:[NSString stringWithFormat:@"Value_%d",dutNum]];
        [self setValue:isPass?testDisplayMesg:@"No Error Occurred" forKey:[NSString stringWithFormat:@"TestMessage_%d",dutNum]];
        
        float temp=0.0f;
        
        if([[NSScanner scannerWithString:testDisplayMesg] scanFloat:&temp])
        {
            [self setValue:testDisplayMesg forKey:[NSString stringWithFormat:@"TestValue_%d",dutNum]];
        }
        else
        {
            [self setValue:!isPass?@"1":@"0" forKey:[NSString stringWithFormat:@"TestValue_%d",dutNum]];
        }
    }
}

-(void) print:(int)dutNum
{
    NSLog(@"----------------------------------%d----------------------------------------",_Order);
    NSLog(@"%@ %@ %@ %@ %@ %@ (%d)",_Name,_Validator,_Command,_Min,_Max,_Unit,_isSkip);
    NSLog(@"Value:%@",[self valueForKey:[NSString stringWithFormat:@"Value_%d",dutNum]]);
    NSLog(@"Result:%@",[self valueForKey:[NSString stringWithFormat:@"Result_%d",dutNum]]);
    NSLog(@"Time:%f",[[self valueForKey:[NSString stringWithFormat:@"Time_%d",dutNum]] floatValue]);
    NSLog(@"TestValue:%@",[self valueForKey:[NSString stringWithFormat:@"TestValue_%d",dutNum]]);
    NSLog(@"TestMessage:%@",[self valueForKey:[NSString stringWithFormat:@"TestMessage_%d",dutNum]]);
    NSLog(@"isPass:%@",[self valueForKey:[NSString stringWithFormat:@"isPass_%d",dutNum]]);
}
@end
