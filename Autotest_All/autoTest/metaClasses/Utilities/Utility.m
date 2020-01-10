//
//  Utility.m
//  autoTest
//
//  Created by May on 14/9/9.
//  Copyright (c) 2014年 TOM. All rights reserved.
//

#import "Utility.h"
#import <CoreImage/CIFilter.h>
#import <CoreImage/CIContext.h>
@implementation Utility

+(void)DEMO
{
    NSLog(@"123 => %d",[Utility isInt:123]);
    NSLog(@"12.3 => %d",[Utility isInt:12.3]);
    NSLog(@"12.0 => %d",[Utility isInt:12.0]);
    NSLog(@"int 12 => %@",[Utility convertIntToHexStr:12]);
    NSLog(@"hex 0xDF => %d",[Utility convertHexStrToInt:@"0xDF"]);
    NSLog(@"hex AB => %d",[Utility convertHexStrToInt:@"AB"]);
    NSLog(@"Dec 123 => %d",[Utility convertDecStrToInt:@"123"]);
    NSLog(@"Str 0x1A => %d",[Utility convertStringToInt:@"0x1A"]);
    NSLog(@"Str 01234 => %d",[Utility convertStringToInt:@"01234"]);
    NSLog(@"Str A => %d (X)",[Utility convertStringToInt:@"A"]);
    NSLog(@"Time 12 HR => %@", [Utility getTimeBy12hr]);
    NSLog(@"between str => %@", [Utility getBetweenKeyWords: @"abc123def" firstWord:@"abc" secendWord:@"def"]);
    NSLog(@"catch str = > %@",[Utility catchString:@"abc123def" specifyString:@"abc" validLen:3]);
    NSLog(@"0xfb 2's Complement = > %ld",[Utility TwoComplement:0xfb TotalBit:8]);
    NSLog(@"0xfffb 2's Complement = > %ld",[Utility TwoComplement:0xfffb TotalBit:14]);
    NSLog(@"0x3ffb 2's Complement = > %ld",[Utility TwoComplement:0x3ffb TotalBit:14]);
    NSLog(@"0xfffffffb 2's Complement = > %ld",[Utility TwoComplement:0xfffffffb TotalBit:32]);
}

+(bool) isInt:(double) value
{
    if((int)value == value)
        return true;
    else
        return false;
}

#pragma mark convert Type
+(int) convertDecStrToInt:(NSString *)str
{
    int intValue;
    [[NSScanner scannerWithString:str] scanInt:&intValue];
    return  intValue;
}

+(int) convertHexStrToInt:(NSString *)str
{
    unsigned int intValue;
    [[NSScanner scannerWithString:str] scanHexInt:&intValue];
    return  intValue;
}

+(int) convertStringToInt:(NSString *)str
{
    if ([str characterAtIndex:0] == '0' && [str characterAtIndex:1] == 'x')
        return [Utility convertHexStrToInt:str];
    else
        return [Utility convertDecStrToInt:str];
}

+(NSString *) convertIntToHexStr:(int) value
{
    return [NSString stringWithFormat:@"%02X",value];
}

+(void) convertStrByPair:(NSString*)str toCharArr:(unsigned char[]) output
{
    int len = (int)[str length];
    const short keyLen=len/2;
    
    if(len % 2 ==0)
    {
        for (int i=0,loc = 0 ; i<keyLen; i++, loc+=2)
        {
            NSString *hexByte=[str substringWithRange:NSMakeRange(loc, 2)];
            output[i]=[Utility convertHexStrToInt:hexByte];
        }
    }
}

+(NSString *)convertToHexStr:(NSString *)dataStr
{
    NSString *dataByHex=@"";
    
    if ([dataStr length]>0)
    {
        for (int i=0; i<[dataStr length]; i++)
        {
            if (i<=64)
            {
                if (i!=[dataStr length]-1)
                {
                    dataByHex=[dataByHex stringByAppendingFormat:@"%02X ",[dataStr characterAtIndex:i]];
                }
                else
                    dataByHex=[dataByHex stringByAppendingFormat:@"%02X",[dataStr characterAtIndex:i]];
            }
            else
                break;
        }
        return dataByHex;
    }
    return @"EMPTY";
}

+(NSString *)ConvertFloatToHex:(float)floatVal
{
    char *f_char = (char *)&floatVal;
    return [NSString stringWithFormat:@"%02X %02X %02X %02X",*(f_char+3)&0xff,*(f_char+2)&0xff,*(f_char+1)&0xff,*(f_char)&0xff];
}

+(NSString *) convertHexStrToStr:(NSString*)hexStr
{
    NSMutableString *tmp = [NSMutableString stringWithString:@""];
    NSArray *arr = [hexStr componentsSeparatedByString:@" "];
    for (int i = 0; i < [arr count]; i++)
        [tmp appendString:[NSString stringWithFormat:@"%c",[Utility convertHexStrToInt:[arr objectAtIndex:i]]]];
    return tmp;
}

# pragma mark Time Format
+(NSString*) getTimeForLocalFolder
{
    NSDate *localDateTime=[NSDate date];
    NSDateFormatter *dateTimeFormat=[[[NSDateFormatter alloc]init] autorelease];
    dateTimeFormat.dateFormat=@"yyyy-MM-dd";
    NSString *dateStr=[dateTimeFormat stringFromDate:localDateTime];
    return dateStr ;
}
+(NSString*) getTimeForFolder
{
    NSDate *localDateTime=[NSDate date];
    NSDateFormatter *dateTimeFormat=[[[NSDateFormatter alloc]init] autorelease];
    dateTimeFormat.dateFormat=@"yyyy-MM-dd(HH_mm)";
    NSString *dateStr=[dateTimeFormat stringFromDate:localDateTime];
    return dateStr ;
}

+(NSString*) getTimeForFile
{
    NSDate *localDateTime=[NSDate date];
    NSDateFormatter *dateTimeFormat=[[[NSDateFormatter alloc]init] autorelease];
    dateTimeFormat.dateFormat=@"yyyy-MM-dd(HH_mm_ss)";
    NSString *dateStr=[dateTimeFormat stringFromDate:localDateTime];
    return dateStr ;
}

+(NSString*) getTimeBy12hr
{
    NSDate *localDateTime=[NSDate date];
    NSDateFormatter *dateTimeFormat=[[[NSDateFormatter alloc]init] autorelease];
    [dateTimeFormat setAMSymbol:@"AM"];
    [dateTimeFormat setPMSymbol:@"PM"];
    dateTimeFormat.dateFormat=@"yyyy-MM-dd-hh-mm-ss a";
    
    NSString *dateStr=[dateTimeFormat stringFromDate:localDateTime];
    return dateStr ;
}

+(NSString*) getTimeBy24hr
{
    NSDate *localDateTime=[NSDate date];
    NSDateFormatter *dateTimeFormat=[[[NSDateFormatter alloc]init] autorelease];
    dateTimeFormat.dateFormat=@"yyyy-MM-dd-HH-mm-ss";
    
    NSString *dateStr=[dateTimeFormat stringFromDate:localDateTime];
    return dateStr ;
}

+(NSString*) getTimeBy24hrStdFormate
{
    NSDate *localDateTime=[NSDate date];
    NSDateFormatter *dateTimeFormat=[[[NSDateFormatter alloc]init] autorelease];
    dateTimeFormat.dateFormat=@"yyyy/MM/dd HH:mm:ss";
    
    NSString *dateStr=[dateTimeFormat stringFromDate:localDateTime];
    return dateStr ;
}

# pragma mark String Process
+(NSString*) catchString:(NSString* )orgString specifyString:(NSString*) speStr validLen:(int) len
{
    NSUInteger idx = [orgString rangeOfString:speStr].location;
    if (idx != NSNotFound)
    {
        if (idx+[speStr length]+len > [orgString length])
            return @"";
        return [orgString substringWithRange:NSMakeRange(idx+[speStr length], len)];
    }
    return @"";
}

+(NSString*) getBetweenKeyWords:(NSString*) orgString firstWord:(NSString*) word1 secendWord:(NSString*) word2
{
    if ([orgString rangeOfString:word1].length>0 && [orgString rangeOfString:word2].length>0)
    {
        int start=(int)[orgString rangeOfString:word1].location+(int)[word1 length];
        int len=(int)[orgString rangeOfString:word2].location-start;
        
        if (start > 0 && len > 0)
            return [orgString substringWithRange:NSMakeRange(start, len)];
    }
    return @"";
}

+(NSString *)cleanStr:(NSString *)source
{
    if ([source length]>0)
    {
        source=[source stringByReplacingOccurrencesOfString:@"\n" withString:@"_"];
        source=[source stringByReplacingOccurrencesOfString:@"\r" withString:@"_"];
        source=[source stringByReplacingOccurrencesOfString:@"," withString:@"_"];
        source=[source stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        return source;
    }
    return @"Empty";
}

# pragma mark ADC Formula
+(float) getADCByDigital:(float)ADC RefVoltage:(float)Vref Resolution:(int)bits
{
    return ADC / (powf(2, bits) -1) * Vref;
}

# pragma GAIN / OFFSET
+(float) getGainFromADCLow:(float)ADC_low DMMLow:(float)DMM_low ADCHigh:(float)ADC_high DMMHigh:(float)DMM_high
{
    return (DMM_high-DMM_low) / (ADC_high-ADC_low);
}
+(float) getOffsetFromADCLow:(float)ADC_low DMMLow:(float)DMM_low ADCHigh:(float)ADC_high DMMHigh:(float)DMM_high
{
    return DMM_low - ADC_low*[Utility getGainFromADCLow:ADC_low DMMLow:DMM_low ADCHigh:ADC_high DMMHigh:DMM_high];
}

# pragma mark MAX11617_Calculate_ADC
+(float)getMAX11617_BipADC:(unsigned short)digit
{
    unsigned short raw = [Utility MAX11617_ADC_Raw:digit];
    return [Utility getADCByDigital:raw RefVoltage:2.048/2 Resolution:11] * [Utility MAX11617_ADC_Polar:digit];
}

+(unsigned short)MAX11617_ADC_Raw:(unsigned short)digit
{
    if ([Utility MAX11617_ADC_Polar:digit]==-1)
    {
        digit = ~digit & 0xFFF;
        digit += 1 ;
    }
    return digit;
}

+(signed short)MAX11617_ADC_Polar:(unsigned short)digit
{
    if ((digit & 0x800)!=0)    // check negative
        return -1;
    return 1 ;
}

# pragma mark Mean & Stardand Deviation
+(float) getMeanByNumArr:(NSMutableArray *) numArr
{
    NSExpression *mean = [NSExpression expressionForFunction:@"average:" arguments:@[[NSExpression expressionForConstantValue:numArr]]];
    return [[mean expressionValueWithObject:nil context:nil] floatValue];
}
+(float) getStddevByNumArr:(NSMutableArray *) numArr
{
    NSExpression *mean = [NSExpression expressionForFunction:@"stddev:" arguments:@[[NSExpression expressionForConstantValue:numArr]]];
    return [[mean expressionValueWithObject:nil context:nil] floatValue];
}

#pragma mark save UART Log
+(NSString *)saveUartLogByData:(NSMutableString *)data SrNm:(NSString*)sn folderName:(NSString*)fName
{
    NSString *fileName = [NSString stringWithFormat:@"%@-%@.txt",[Utility getTimeForFile],sn];
    NSString *folderPath = [NSString stringWithFormat:@"/vault/IACHostLogs/%@", fName];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",folderPath,fileName];
    [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    if ([data writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil])
    {
        NSLog(@"UART log save:%@",filePath);
        return filePath;
    }
    return @"";
}

+(double)calc_color_temp:(double)r green:(double)g blue:(double)b
{
    double x = (-0.14282 * r) + (1.54924 * g) + (-0.95641 * b);
    double y = (-0.32466 * r) + (1.57837 * g) + (-0.73191 * b);
    double z = (-0.68202 * r) + (0.77073 * g) + ( 0.56332 * b);

    double denom = x+y+z;
    if(denom == 0)
        return 0;

    double xc = (x) / (x + y + z);
    double yc = (y) / (x + y + z);

    double n = (xc - 0.3320) / (0.1858 - yc);

    double cct = (449.0 * pow(n,3)) + (3525.0 * pow(n,2)) + (6823.3 * n) + 5520.33;

    return cct;
}

+(double)calc_illuminance:(double)r green:(double)g blue:(double)b
{
    double illuminance = (-0.32466 * r) + (1.57837 * g) + (-0.73191 * b);
    return illuminance;
}


#pragma mark base64 encode/decode

+(NSString*)encode:(NSString*)plainString
{
    NSData *plainData=[plainString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String=[plainData base64EncodedStringWithOptions:0];
    return base64String;
}

+(NSString*)decode:(NSString*)base64String
{
    NSData *decodedData=[[[NSData alloc] initWithBase64EncodedString:base64String options:0] autorelease];
    NSString *decodedString=[[[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding] autorelease];
    return decodedString;
}

#pragma mark QR code
+(NSImage *)QRcodeFromStr:(NSString *)string width:(int)w height:(int)h
{
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:[string dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    NSCIImageRep *imgRep = [NSCIImageRep imageRepWithCIImage:qrFilter.outputImage];
    NSSize size = {w, h};
    [imgRep setSize:size];
    NSImage *img = [[[NSImage alloc] initWithSize:imgRep.size] autorelease];
    [img addRepresentation:imgRep];
    
    return img;
}

+(void)displayQRcodeMesgBox:(NSString *)sn
{
    NSAlert *alert=[[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:sn];
    [alert setIcon:[self QRcodeFromStr:sn width:100 height:100]];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert runModal];
}

+ (BOOL)showMessageBox:(MesgBoxType)tipsType text:(NSString*)text
{
    NSAlert *alert=[[[NSAlert alloc] init] autorelease];
    [alert setInformativeText:text];
    
    if (tipsType==Question)
    {
        [alert setMessageText:@"Question:"];
        [alert addButtonWithTitle:@"YES"];
        [alert addButtonWithTitle:@"NO"];
        [alert setIcon:[NSImage imageNamed:@"Qimg"]];
    }
    else if (tipsType==Error)
    {
        [alert setMessageText:@"Error:"];
        [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [alert addButtonWithTitle:@"Confirm"];
    }
    else if (tipsType==Information)
    {
        [alert setMessageText:@"Information:"];
        [alert setIcon:[NSImage imageNamed:NSImageNameInfo]];
        [alert addButtonWithTitle:@"OK"];
    }
    
    return  ([alert runModal]==NSAlertFirstButtonReturn)?YES:NO;
}

#pragma mark Process app function
+(BOOL)awakeAppByBundleID:(NSString*)identity
{
    NSArray* apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:identity];
    if([apps count]>0)
    {
        [(NSRunningApplication*)[apps objectAtIndex:0] activateWithOptions: NSApplicationActivateAllWindows];
        return true;
    }
    return false;
}
// 10.9+ only, see this url for compatibility:
// http://stackoverflow.com/questions/17693408/enable-access-for-assistive-devices-programmatically-on-10-9
+(BOOL)checkAppleScriptAccessibility
{
    NSDictionary* opts = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts);
}

//2's Complement
+(signed long)TwoComplement:(unsigned long)original TotalBit:(int)Bits
{
    if(Bits>32 || Bits<=0)
    {
        NSLog(@"TwoComplement doesn't support this len:%d",Bits);
        return 0;
    }
    
    signed long val=original & ((1L<<Bits)-1);
    if (original & (1L<<(Bits-1)))
        val=(((~val) & ((1L<<Bits)-1))+1)*-1;
    return val;
}
@end
