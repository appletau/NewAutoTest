//
//  ControlBits.m
//  autoTest
//
//  Created by Li Richard on 13-8-28.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "ControlBits.h"
#include "libControlBits.h"

@implementation ControlBits
@synthesize CBenable;
@synthesize delegate;
@synthesize CBsToCheckSize;
@synthesize CBsToCheckOn;

//### Call Skunk CB APIs to get CB info ###
//$IP_SetControlBit = call_IP (StationSetControlBit);

-(id)init
{
    if (self = [super init])
    {
        testMessage = [[NSMutableString alloc] initWithFormat:@"NA"];
    }
    return self;
}

-(void)dealloc
{
    [testMessage release];
    [super dealloc];
}

- (NSString *) testMessage
{
    return testMessage;
}

- (BOOL)startHandler:(NSString*)myCBindex
{    
    if ([self CBsToCheck])
    {
        if(CBsToCheckSize==0)   return TRUE;//Tim:if CONTROL BIT TO CHECK is OFF, please don’t check the array and allowed fail count.
        int stationAllowedFC = [self StationFailCountAllowed];
        if(stationAllowedFC==-1)    return TRUE;
        int diagFC = [delegate CBRead_Fail_count:myCBindex];

        if (diagFC == DefectFailCount)
        {
            [testMessage setString:@"Can not get fail count from diag"];
            return FALSE;
        }
        
        if ((diagFC < stationAllowedFC))
        {
            return TRUE;
        }
        else
        {
            [testMessage setString:[NSString stringWithFormat:@"CB Error:Relative Fail Count: %d %d",diagFC,stationAllowedFC]];
            [delegate CBErrorInfoToPDCA:@"CB Error" SubTest:@"Over Allowed Relative Fail Count" failMesg:testMessage];
        }
    }
    
    return FALSE;
}

- (BOOL)CBsToClearOnFail
{
    size_t size;
    bool cbResult = ControlBitsToClearOnFail(NULL,&size);  // if size=0 return true;
    
    if ((size > 0) && cbResult)
    {
        int *array = (int *)malloc(size*sizeof(int));
        cbResult = ControlBitsToClearOnFail(array,&size);
        
        if(cbResult)
        {
            for(int i = 0; i < size;i++)
            {
                NSLog(@"%0x02x:%d \n", array[i],array[i]);
                [delegate CBWrite:[[NSString stringWithFormat:@"0x%x",array[i]] uppercaseString] forResult:CB_INCOMPLETE];
            }
            
            free(array);
            //NSLog(@"returned true from\n");
        }
    }
    else if(!cbResult)
        NSLog(@"CB Error(CBsToClearOnFail):reply was not successful from first call (size=%ld)",size);
    
    return true;
}

- (BOOL)CBsToClearOnPass
{
    size_t size;
    bool cbResult = ControlBitsToClearOnPass(NULL,&size);  // if size=0 return true;
    
    if((size > 0) && cbResult)
    {
        int *array = (int *)malloc(size*sizeof(int));
        cbResult = ControlBitsToClearOnPass(array,&size);
        
        if(cbResult)
        {
            for(int i=0; i<size;i++)
            {
                NSLog(@"%0x02x:%d \n", array[i],array[i]);
                [delegate CBWrite:[[NSString stringWithFormat:@"0x%x",array[i]] uppercaseString] forResult:CB_INCOMPLETE];
            }
            free(array);
            //NSLog(@"returned true from\n");
        }
    }
    else if (!cbResult)
        NSLog(@"CB Error(CBsToClearOnPass):reply was not successful from first call (size=%ld)",size);
    
    return true;
}

- (BOOL)CBsToCheck
{
    int array[ARRAYSIZE];
    char stationArray[ARRAYSIZE][ARRAYSIZE];
    size_t size;
    
    for (int i = 0;i<ARRAYSIZE;i++)
        for (int j = 0; j < ARRAYSIZE; j++)
            stationArray[i][j] = 0;
    
    CBsToCheckOn=IP_CBsToCheck(array,&size,stationArray)?true:false;
    if(CBsToCheckOn==false)   // if size=0 return true;
        NSLog(@"CBsToCheck not successful (size=%ld)",size);
    
    CBsToCheckSize=size;
    
    for(int i = 0 ; i< size;i++)
    {
        NSString *strResult = [[delegate CBRead:[NSString stringWithFormat:@"0x%x",array[i]]] uppercaseString];
        
        if (![strResult isEqualToString:CB_PASS])
        {
            [testMessage setString:[NSString stringWithFormat:@"CB Error:0x%X %s not PASS",array[i], stationArray[i]]];
            [delegate CBErrorInfoToPDCA:@"CB Error" SubTest:@"CB not PASS" failMesg:testMessage];
            return false;
        }
    }
    return true;
}

- (BOOL)SetCBsEnable
{
    return setCb();
}

- (int)StationFailCountAllowed
{
    return IP_StationFailCountAllowed();
}

+ (const char *)getVersion
{
    return getAuthVersion();
}

-(NSString *)test
{
    return @"";
}

+ (unsigned char*)getSHA1ByKey:(unsigned char*)secretKey andNonce:(unsigned char*)nonce
{
    return IP_CBToCreateSHA1(secretKey, nonce);
}
@end
