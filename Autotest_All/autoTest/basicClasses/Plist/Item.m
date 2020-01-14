//
//  Item.m
//  propertyTest
//
//  Created by may on 09/04/2019.
//  Copyright © 2019 IAC. All rights reserved.
//

#import "Item.h"

@implementation Item
@synthesize MinFloatValue,MaxFloatValue;

-(id) init:(NSDictionary*)dic
{
    if(self=[super init])
    {
        _Name=[dic[@"name"] copy];
        _Validator=[dic[@"validator"] copy];
        _Command=[dic[@"command"] copy];
        
        self.Min=dic[@"min"];
        self.Max=dic[@"max"];

        _Unit=[dic[@"unit"] copy];
        _isSkip=[dic[@"skip"] boolValue];
        
        if(_Name==nil)_Name=@"";
        if(_Validator==nil)_Validator=@"";
        if(_Command==nil)_Command=@"";
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

-(void) setResult:(NSString *)resultStr displayStr:(NSString *)displayStr valueStr:(NSString *)valueStr item:(Item*)item dutNum:(int)dutNum
{
    if([resultStr isEqualToString:@""] && displayStr==nil && valueStr==nil && item==nil)//because of test Done so must reset all data
    {
        [self setValue:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"isPass_%d",dutNum]];
        [self setValue:@"" forKey:[NSString stringWithFormat:@"Value_%d",dutNum]];
        [self setValue:@"" forKey:[NSString stringWithFormat:@"Result_%d",dutNum]];
        [self setValue:@"0" forKey:[NSString stringWithFormat:@"Time_%d",dutNum]];
        [self setValue:@"NA" forKey:[NSString stringWithFormat:@"TestValue_%d",dutNum]];
        [self setValue:@"" forKey:[NSString stringWithFormat:@"TestMessage_%d",dutNum]];
        return;
    }
    
    BOOL isPass=[resultStr isEqualToString:@"FAIL"]?NO:YES;
    [self setValue:[NSNumber numberWithBool:isPass] forKey:[NSString stringWithFormat:@"isPass_%d",dutNum]];
    
    //setup internal Result_N==>UI result display, 4 option:PASS/FAIL/SKIP or Empty
    NSDictionary *color = @{NSForegroundColorAttributeName:[resultStr isEqualToString:@"PASS"]?[NSColor greenColor]:([resultStr isEqualToString:@"FAIL"]?[NSColor redColor]:[NSColor yellowColor])};
    NSAttributedString *result=[[NSAttributedString alloc] initWithString:resultStr attributes:color];
    [self setValue:result forKey:[NSString stringWithFormat:@"Result_%d",dutNum]];
    [result release];
    
    //setup internal TestValue_N==>measure value or P/F mapping to 0/1 for pudding, must float/INT format string
    //setup internal TestMessage_N==>explain the TestValue_N for pudding
    float val=0.0f;
    NSString *mesg=@"No Error Occurred";
    
    if([[NSScanner scannerWithString:valueStr] scanFloat:&val])//if valueStr is a real number
    {
        if([item.MinStr length]>0 && [item.MaxStr length]>0)
        {
            if(val>=item.MinFloatValue && val<=MaxFloatValue)
                mesg=@"No Error Occurred (Within limits)";
            else if(val<item.MinFloatValue)
                mesg=@"Less than the lower limit";
            else if(val>item.MaxFloatValue)
                mesg=@"Greater than the upper limit";
        }
        else if ([item.MinStr length]>0 && [item.MaxStr length]==0)//no upper limit case
            mesg=(val>=item.MinFloatValue)?@"No Error Occurred (Within limits)":@"Less than the lower limit";
        else if ([item.MaxStr length]>0 && [item.MinStr length]==0)//no lower limit case
            mesg=(val<=item.MaxFloatValue)?@"No Error Occurred (Within limits)":@"Greater than the upper limit";

        [item setValue:displayStr forKey:[NSString stringWithFormat:@"Value_%d",dutNum]];
        [self setValue:valueStr forKey:[NSString stringWithFormat:@"TestValue_%d",dutNum]];
        [self setValue:mesg forKey:[NSString stringWithFormat:@"TestMessage_%d",dutNum]];
        return;
    }
    
    [item setValue:displayStr forKey:[NSString stringWithFormat:@"Value_%d",dutNum]];
    [self setValue:!isPass?@"1":@"0" forKey:[NSString stringWithFormat:@"TestValue_%d",dutNum]];
    [self setValue:isPass?@"No Error Occurred":displayStr forKey:[NSString stringWithFormat:@"TestMessage_%d",dutNum]];
}

-(void) setMin:(NSNumber *)num
{
    @synchronized(self)
    {
        if(num!=nil)
        {
            _MinStr=[num stringValue];
            [[NSScanner scannerWithString:_MinStr] scanFloat:&MinFloatValue];
        }
        else
            _MinStr=@"";
    }
}

-(void) setMax:(NSNumber *)num
{
    @synchronized(self)
    {
        if(num!=nil)
        {
            _MaxStr=[num stringValue];
            [[NSScanner scannerWithString:_MaxStr] scanFloat:&MaxFloatValue];
        }
        else
            _MaxStr=@"";
    }
}

-(NSString *)Min
{
    return [self MinStr];
}

-(NSString *)Max
{
    return [self MaxStr];
}


-(void) print:(int)dutNum
{
    NSLog(@"----------------------------------%d----------------------------------------",_Order);
    NSLog(@"%@ %@ %@ %@ %@ %@ (%d)",_Name,_Validator,_Command,_MinStr,_MaxStr,_Unit,_isSkip);
    NSLog(@"Value:%@",[self valueForKey:[NSString stringWithFormat:@"Value_%d",dutNum]]);
    NSLog(@"Result:%@",[self valueForKey:[NSString stringWithFormat:@"Result_%d",dutNum]]);
    NSLog(@"Time:%f",[[self valueForKey:[NSString stringWithFormat:@"Time_%d",dutNum]] floatValue]);
    NSLog(@"TestValue:%@",[self valueForKey:[NSString stringWithFormat:@"TestValue_%d",dutNum]]);
    NSLog(@"TestMessage:%@",[self valueForKey:[NSString stringWithFormat:@"TestMessage_%d",dutNum]]);
    NSLog(@"isPass:%@",[self valueForKey:[NSString stringWithFormat:@"isPass_%d",dutNum]]);
}
@end
