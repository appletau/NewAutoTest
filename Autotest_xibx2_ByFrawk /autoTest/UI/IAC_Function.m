//
//  Function.m
//  autoTest
//
//  Created by May on 4/30/13.
//  Copyright (c) 2013 TOM. All rights reserved.
//

#import "IAC_Function.h"

#define UOP_PASSWORD [[PlistIO sharedPlistIO] getObjForKey:@"UOP_PASSWORD"]
#define MY_CB_INDEX [plist getObjForKey:@"MY_CB"]
#define NA_STR @"NA"
#define DEFAULT_MESSAGE @"no error"
#define ENDING_SYMBOL @":-)"
#define NO_ANSWER   0
#define IOS_MODE    1
#define IBOOT_MODE  2
#define DIAG_MODE   3

NSString *QT2_Key   = @"RTc3M0NFOTk0QjMxQzg4MjRDOTVGMzFDQkU2RUE2NTU1NUJDQTgyMw==";
NSString *TOUCH_Key = @"Qjk1MzZERjUxNDBGRkU3OTZDM0M1MDg1MzFDRURFQUU1NTFGM0FFMQ==";

@implementation IAC_Function
@synthesize testValue;
@synthesize testMessage;
@synthesize testDisplayMessage;
@synthesize isPass;
@synthesize isTimeout;
@synthesize skipBelowTest;
@synthesize isStartPudding;

-(id)initWithDutNum:(const int)dutNum withThreadsync:(ThreadSync*)threadSync
{
    if(self=[super init])
    {
        testValue=[[NSMutableString alloc] initWithString:NA_STR];
        testMessage=[[NSMutableString alloc] initWithString:NA_STR];
        testDisplayMessage=[[NSMutableString alloc] initWithString:NA_STR];
        isPass=FALSE;
        isTimeout=FALSE;
        
        my_thread_index=dutNum;
        threadSyncStatus=threadSync;
        plist=[PlistIO sharedPlistIO];
        isAllowPudding=[plist isAllowPudding];
        dev=[plist getEquipment:[NSString stringWithFormat:@"THRD%d_DevUART",my_thread_index]];
        skipBelowTest=FALSE;
        
        SecretKeyTable=[[NSMutableDictionary alloc] initWithObjectsAndKeys:[Utility decode:QT2_Key],@"0x82",[Utility decode:TOUCH_Key],@"0x90",nil];
        
        shellcmd=[[ShellCmd alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [testValue release];
    [testMessage release];
    [testDisplayMessage release];
    [SecretKeyTable release];
    [super dealloc];
}

-(void)timeoutAction:(NSString*)cmd
{
    NSLog(@"ERROR: cmd:%@ time out",cmd);
    isPass=FALSE;
    isTimeout=TRUE;
    [testValue setString:@"1"]; //for InstantPudding value (FAIL=1 PASS=0)
    [testMessage setString:[NSString stringWithFormat:@"execute %@ cmd is timeout",cmd]];//for InstantPudding message
    [testDisplayMessage setString:testMessage]; //for UI display
}

-(id)catchObj:(NSMutableArray *)args name:(int)argName
{
    switch (argName)
    {
        case MethodName:
            return [args objectAtIndex:MethodName];
        case Command:
            return [args objectAtIndex:Command];
        case ValidForm:
            return [args objectAtIndex:ValidForm];
        case Min:
            return [args objectAtIndex:Min];
        case Max:
            return [args objectAtIndex:Max];
        case Unit:
            return [args objectAtIndex:Unit];
        case SN:
            return [[args objectAtIndex:SNs] objectAtIndex:SN-SN];
        case MLB_SN:
            return [[args objectAtIndex:SNs] objectAtIndex:MLB_SN-SN];
        case MPN:
            return [[args objectAtIndex:SNs] objectAtIndex:MPN-SN];
        case Region:
            return [[args objectAtIndex:SNs] objectAtIndex:Region-SN];
        case pudding:
            return [[args objectAtIndex:Other] objectAtIndex:pudding-pudding];
        case controlbits:
            return [[args objectAtIndex:Other] objectAtIndex:controlbits-pudding];
        case validatorPW:
            return [[args objectAtIndex:Other] objectAtIndex:validatorPW-pudding];
        default:
            break;
    }
    return nil;
}

-(void)EquipLogDemo:(NSMutableArray *)args
{
    init_before_test
    //set log folder path,default is "/vault/Equipments_Log"
    [dev setLogFolderPath:@"/vault/IACHostLogs/Equipments_Log"];
    //or//[Equipments setLogFolderPath:@"/vault/IACHostLogs/Equipments_Log"];
    
    //test for saving delay time(sec) in current thread log
    [Equipments delayWithSecond:my_thread_index*4 forThread:my_thread_index];
    
    //test for clearing current thread log
    [Equipments clearLogFileWithThread:my_thread_index];
    
    //test for adding fixture cmd & resp to current thread log
    [dev writeToDevice:@"Test For 'writeToDevice' Command!"];
    [dev readFromDevice];
    [dev queryRawDataByCmd:@"Test For 'queryRawDataByCmd' Command!" strWaited:@"!" retry:1 timeout:2];
    
    //test for saving delay time(ms)  in current thread log
    [Equipments delayWithMicorSecond:1000 forThread:my_thread_index];
    
    //test for adding device cmd & resp to current thread log
    [dev writeToDevice:@"Test For 'writeToDevice' Command!"];
    [dev readFromDevice];
    [dev queryRawDataByCmd:@"Test For 'queryRawDataByCmd' Command!" strWaited:@"!" retry:1 timeout:2];
    
    //test for adding extra message(shell cmd) to current thread log
    NSString *cmd = @"ls";
    NSString *resp = [shellcmd runBashCommandNew:cmd];
    [Equipments attachLogFileWithTitle:@"shellCMD"
                              withDate:[Utility getTimeBy24hr]
                           withMessage:[NSString stringWithFormat:@"SEND:%@",cmd]
                             forThread:my_thread_index];
    [Equipments attachLogFileWithTitle:@"shellCMD"
                              withDate:[Utility getTimeBy24hr]
                           withMessage:[NSString stringWithFormat:@"RESP:\n%@",resp]
                             forThread:my_thread_index];
    
    //save log
    NSMutableString *filePath=[[NSMutableString alloc] init];
    
    if(dev!=nil)
        [filePath setString:[dev saveLogWithFileName:[NSString stringWithFormat:@"%@_Device_Test_%d.txt",[Utility getTimeBy24hr],my_thread_index]]];
    else
        [filePath setString:[Equipments saveLogWithFileName:[NSString stringWithFormat:@"%@_Device_Test_%d.txt",[Utility getTimeBy24hr],my_thread_index] forThread:my_thread_index]];//or//
    
    isPass = true;
    [testDisplayMessage setString:filePath];
}

-(void)DEMO:(NSMutableArray *)args
{
    NSLog(@"============START DEMO============");
    init_before_test
    sleep(3);//simulate working time jsut for test
    NSLog(@"------------Arguments------------");
    NSLog(@"SN: %@",[self catchObj:args name:SN]);
    NSLog(@"method name: %@",[self catchObj:args name:MethodName]);
    NSLog(@"command: %@",[self catchObj:args name:Command]);
    NSLog(@"max: %@",[self catchObj:args name:Max]);
    NSLog(@"min: %@",[self catchObj:args name:Min]);
    NSLog(@"unit: %@",[self catchObj:args name:Unit]);
    NSLog(@"valid: %@",[self catchObj:args name:ValidForm]);

    if ([dev isReady])
        [dev DEMO];

    [testDisplayMessage setString:[NSString stringWithFormat:@"Thread:%d",my_thread_index]];
    [testValue setString:[NSString stringWithFormat:@"%d",my_thread_index]];
    [testMessage setString:(isPass=YES)?@"well done":@"error occurred"];
    NSLog(@"============END DEMO============");
}

-(void)Test:(NSMutableArray *)args
{
    init_before_test
    
    
    int v=arc4random()%4+1;
    [testDisplayMessage setString:[NSString stringWithFormat:@"%d",v]];
    //[testDisplayMessage setString:[NSString stringWithFormat:@"%d",my_thread_index]];
    [testMessage setString:(isPass=YES && v==1)?@"well done":@"error occurred"];
}

-(void)EnterDiag:(NSMutableArray *)args
{
    init_before_test
    
    if ([self EnterDiags])
    {
        isPass = true;
        [testDisplayMessage setString:ENDING_SYMBOL];
    }
    else
    {
        skipBelowTest=true;
        [testDisplayMessage setString:@"Enter diags Failed"];
        [testMessage setString:testDisplayMessage];
    }
}

-(void)RTC_Set:(NSMutableArray *)args
{
    init_before_test
    
    if([dev setRTC])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSString *RTCtime = [dev getRTC];
        NSArray *timeArr = [RTCtime componentsSeparatedByString:@"."];
        
        if ([timeArr count] == 6)
        {
            NSString *temp = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",timeArr[0],timeArr[1],timeArr[2],timeArr[3],timeArr[4],timeArr[5]];
            NSDate *RTCdate = [dateFormatter dateFromString:temp];
            NSDate *now = [NSDate date];
            
            if ([now timeIntervalSinceDate:RTCdate] <= 5)
            {
                isPass = true;
                [testValue setString:@"1"];
                [testDisplayMessage setString:temp];
                
                if ([self CBWrite:MY_CB_INDEX forResult:CB_INCOMPLETE])
                {
                    NSLog(@"bw incomplete done");
                }
                else
                {
                    NSLog(@"bw incomplete fail");
                }
            }
            else
            {
                [testValue setString:@"0"];
                [testDisplayMessage setString:@"get time string fail"];
                [testMessage setString:@"get os time fail"];
            }
        }
        else
        {
            [testValue setString:@"0"];
            [testDisplayMessage setString:@"rtc get fail"];
            [testMessage setString:@"get rtc fail"];
        }
        [dateFormatter release];
    }
    else
    {
        [testValue setString:@"0"];
        [testDisplayMessage setString:@"rtc set fail"];
        [testMessage setString:@"set rtc fail"];
    }
    
}

#pragma mark pudding fucntion
-(BOOL)Pudding_checkAMIOK:(NSMutableArray *)args
{
    puddings = [self catchObj:args name:pudding];
    
    if (![puddings UUT_amIOkay])
    {
        if ([plist isAllowAuditMode]) return TRUE;
        
        NSString *errStr = [NSString stringWithFormat:@"%@",[puddings amiokay_msg]];
        NSLog(@"Pudding_checkAMIOK Fail: %@",errStr);
        
        if (0)
        {
            ValidatorPW *validPW = [self catchObj:args name:validatorPW];
            if([errStr containsString:@"OVER 3 UNITS"] || [errStr containsString:@"20%"])
            {
                if([validPW checkPasswordMsg:errStr checkPassword:UOP_PASSWORD changeBGcolor:NO])
                    return TRUE;
            }
        }
        
        [testMessage setString:errStr];
        [testDisplayMessage setString:errStr];
        
        return FALSE;
    }
    return TRUE;
}

-(void)CheckPudding:(NSMutableArray *)args
{
    init_before_test
    
    if (![plist isAllowPudding])
    {
        isPass=TRUE;
        return;
    }
    NSString *sn=[self catchObj:args name:SN];
    puddings = [self catchObj:args name:pudding];
    isStartPudding = [puddings startHandler:sn];
    
    if (isStartPudding)
    {
        isPass=TRUE;
        skipBelowTest=false;
        [testValue setString:@"0"];
        [testDisplayMessage setString:@"Start pudding Succeed"];
    }
    else
    {
        skipBelowTest=true;
        [testMessage setString:[NSString stringWithFormat:@"%s",[puddings replyError]]];
        [testDisplayMessage setString:testMessage];
    }
}

-(void)CheckControlBit:(NSMutableArray *)args
{
    init_before_test
    
    if (![plist isAllowPudding]) //for offline test
    {
        isPass=TRUE;
        return;
    }
    
    if ([MY_CB_INDEX isEqualToString:DefectCBIndex]) // for without control bits
    {
        isPass=TRUE;
        return;
    }
    
    ControlBits *controlBit = [self catchObj:args name:controlbits];
    controlBit.delegate = self;
    
    if ([plist isAllowAuditMode])
    {
        isPass=TRUE;
        [testValue setString:@"0"];
        [testDisplayMessage setString:@"Audit Mode"];
        
        int stationAllowedFC = [controlBit StationFailCountAllowed];
        
        if (stationAllowedFC==-1)//stationAllowedFC=-1 means don't care the fail count, just set CB to FAIL
        {
            NSString* my_Status=[self CBRead:MY_CB_INDEX];
            if ([my_Status isEqualToString:@""])
            {
                [testMessage setString:@"CB Read Error"];
                [testDisplayMessage setString:@"CB Read Error on audit mode"];
                [testValue setString:@"1"];
                skipBelowTest=true;
                isPass=false;
            }
            else if(![my_Status isEqualToString:CB_FAIL])
            {
                if (![self CBWrite:MY_CB_INDEX forResult:CB_FAIL])
                {
                    [testMessage setString:@"CB Write FAIL Error"];
                    [testDisplayMessage setString:@"CB Write FAIL Error on audit mode"];
                    [testValue setString:@"1"];
                    skipBelowTest=true;
                    isPass=false;
                }
            }
            return;
        }
        
        int relaFailCount = [self CBRead_Fail_count:MY_CB_INDEX];
        while (relaFailCount != DefectFailCount && relaFailCount < (stationAllowedFC+1))
        {
            if (![self CBWrite:MY_CB_INDEX forResult:CB_FAIL])
            {
                [testMessage setString:@"CB Write FAIL Error"];
                [testDisplayMessage setString:@"CB Write FAIL Error on audit mode"];
                [testValue setString:@"1"];
                skipBelowTest=true;
                isPass=false;
                return;
            }
            relaFailCount = [self CBRead_Fail_count:MY_CB_INDEX];
        }
    }
    else
    {
        BOOL bRet = [controlBit startHandler:MY_CB_INDEX];
        
        if(![controlBit CBsToCheckOn])
        {
            skipBelowTest=true;
            [testMessage setString:@"CBsToCheck is off"];
            [testDisplayMessage setString:@"CBsToCheck is Off"];
            return;
        }
        
        if([controlBit CBsToCheckSize]==0)
        {
            skipBelowTest=true;
            [testMessage setString:@"CBsToCheckSize=0"];
            [testDisplayMessage setString:@"CBsToCheckSize=0"];
            return;
        }
        
        if (!bRet)
        {
            isPass = false;
            skipBelowTest=true;
            [testMessage setString:[controlBit testMessage]];
            [testDisplayMessage setString:testMessage];
        }
        else
        {
            isPass=true;
            [testValue setString:@"0"];
            [testDisplayMessage setString:@"cb startHandle successful"];
        }
    }
}

-(void)SetCB_I:(NSMutableArray *)args
{
    init_before_test
    
    if (![plist isAllowPudding]) //for offline test
    {
        isPass=TRUE;
        return;
    }
    
    if ([MY_CB_INDEX isEqualToString:DefectCBIndex]) // for without control bits
    {
        isPass=TRUE;
        return;
    }
    
    if ([plist isAllowAuditMode])//for audit mode
    {
        isPass=TRUE;
        [testMessage setString:@"Audit Mode"];
        [testDisplayMessage setString:testMessage];
        return;
    }
    
    bool setCbImp=[self CBWrite:MY_CB_INDEX forResult:CB_INCOMPLETE];
    if (!setCbImp)
    {
        isPass=false;
        skipBelowTest=true;
        [testValue setString:@"1"];
        [testMessage setString:@"CB Write Incomplete Error"];
        [testDisplayMessage setString:@"CB Write Incomplete Error"];
    }
    else
    {
        isPass=true;
        [testValue setString:@"0"];
        [testDisplayMessage setString:@"Set CB Incomplete PASS"];
    }
}

-(void)finishWorkHandler:(NSMutableArray *)args
{
    init_before_test_wo_skip
    
    NSMutableString *filePath=[[NSMutableString alloc] init];
    
    //must save the dev log under any case
    if(dev!=nil)
    {
        [filePath setString:[dev saveLogWithFileName:[NSString stringWithFormat:@"%@_Device%d.txt",[Utility getTimeBy24hr],my_thread_index]]];
        [testDisplayMessage setString:[filePath lastPathComponent]];
    }
    
    if ([plist isAllowPudding] && isStartPudding)
    {
        BOOL            replyResult             = NO;
        BOOL            failedAtLeastOneTest    = NO;
        int             count                   = 0;
        unsigned int    priority                = ([plist isAllowAuditMode])?IP_PRIORITY_STATION_CALIBRATION_AUDIT:IP_PRIORITY_REALTIME_WITH_ALARMS;
        
        //TODO:add some attribute eg.[puddings UUT_AddAttribute:@"DRIVER_SN" Value:driver_sn_sting];
        
        char *stationID=(char*)malloc(64*sizeof(char));
        [puddings getGHStationInfo:IP_STATION_ID outputData:stationID];
        [puddings UUT_setDUTPos:[NSString stringWithUTF8String:stationID] Header:[NSString stringWithFormat:@"%d",my_thread_index]];
        free(stationID);
        
        NSLog(@"the test count is %ld",[[plist TestItemList] count]);
        
        for(count=0; count < [[plist TestItemList] count]; count++)
        {
            Item *item=[plist TestItemList][count];
            
            if ([item.Name isEqualToString:[self catchObj:args name:MethodName]]) break;
            // create a test specification for our test
            [puddings UUT_CreateTest];
            
            [puddings UUT_TestSpecSetTestName:[item.Name UTF8String]];
            [puddings UUT_TestSpecSetValue:[[item valueForKey:[NSString stringWithFormat:@"Value_%d",my_thread_index]] UTF8String]];
            [puddings UUT_TestSpecSetLimits:[item.Min UTF8String] Upper_Limits:[item.Max UTF8String]];
            [puddings UUT_TestSpecSetUnits:[item.Unit UTF8String]];
            [puddings UUT_TestSpecSetPriority:priority];
            
            if (item.isSkip)
            {
                [puddings UUT_TestSpecSetResult:TEST_SKIP1];
            }
            else if ([[item valueForKey:[NSString stringWithFormat:@"isPass_%d",my_thread_index]] boolValue])//pass
            {
                [puddings UUT_TestSpecSetResult:TEST_PASS1];
            }
            else//fail
            {
                [puddings UUT_TestSpecSetResult:TEST_FAIL1];
                [puddings UUT_TestSpecSetMessage:[[item valueForKey:[NSString stringWithFormat:@"TestMessage_%d",my_thread_index]] UTF8String]];
                NSLog(@"the failed item is %@",item.Name);
                failedAtLeastOneTest = true;
            }
            
            replyResult = [puddings UUT_AddResult];
            if (!replyResult)
            {
                NSLog(@"add item : %s",[puddings replyError]);
            }
            [puddings UUT_CleanTest];
        }
        
        [puddings UUT_SetStopTime];
        
        //add log as Blob here
        replyResult=[puddings UUT_AddBlob:@"UART_LOG" PathToBlobFile:filePath];
        if (!replyResult)
            NSLog(@"addBlob error :%s",[puddings replyError]);
        //end add log as blob
        
        replyResult = [puddings UUT_Done];
        NSLog(@"replyResult:%d",replyResult);
        NSLog(@"failedAtLeastOneTest:%d",failedAtLeastOneTest);
        if (!replyResult || failedAtLeastOneTest)
        {
            printf("Calling Commit FAIL\n");
            replyResult = [puddings UUT_Commit:TEST_FAIL1];
            
            if (!replyResult)
                NSLog(@"DUT:%d Commit error :%s",my_thread_index,[puddings replyError]);
            else{
                NSLog(@"DUT:%d Commit error :%s",my_thread_index,[puddings replyError]);
            }
            isPass = FALSE;
            NSString *errStr = [NSString stringWithFormat:@"%s",[puddings replyError]];
            NSLog(@"DUT:%d Commit error :%s",my_thread_index,[puddings replyError]);
            
            [testDisplayMessage setString:([errStr length]==0)?@"at least a test item is fail":errStr];
        }
        else
        {
            printf("Calling Commit PASS\n");
            replyResult = [puddings UUT_Commit:TEST_PASS1];
            NSString *errStr = [NSString stringWithFormat:@"%s",[puddings replyError]];
            
            if (replyResult && [errStr length]==0)
            {
                isPass = TRUE;
            }
            else
            {
                isPass = FALSE;
                [testDisplayMessage setString:errStr];
            }
        }
        
        [puddings UUT_Destroy];
        
        //force pass because commit or done fail issue
        if ([plist isAllowAuditMode] && ![testDisplayMessage isEqualToString:@"at least a test item is fail"])
        {
            isPass=TRUE;
        }
    }
    else
    {
        if([plist isAllowPudding])
        {
            [testDisplayMessage setString:@"pudding start handle fail"];
            isPass=FALSE;
        }
        else
            isPass=TRUE;
    }
    
    if([testDisplayMessage isEqualToString:NA_STR])
    {
        [testDisplayMessage setString:@"Done"];
    }
    
    [filePath release];
}

#pragma mark cb access
-(void)cbTest:(NSMutableArray *)args  //this method is just for cb test only
{
    for(int i=0;i<5;i++)
    {
        NSLog(@"read:%@",[self CBRead:MY_CB_INDEX]);
        NSLog(@"write:%d",[self CBWrite:MY_CB_INDEX forResult:CB_INCOMPLETE]);
        NSLog(@"read:%@",[self CBRead:MY_CB_INDEX]);
        NSLog(@"write:%d",[self CBWrite:MY_CB_INDEX forResult:CB_PASS]);
        NSLog(@"read:%@",[self CBRead:MY_CB_INDEX]);
    }
    
    for(int i=0;i<3;i++)
    {
        NSLog(@"read:%@",[self CBRead:MY_CB_INDEX]);
        NSLog(@"write:%d",[self CBWrite:MY_CB_INDEX forResult:CB_FAIL]);
        NSLog(@"read:%@",[self CBRead:MY_CB_INDEX]);
        NSLog(@"write:%d",[self CBWrite:MY_CB_INDEX forResult:CB_INCOMPLETE]);
        NSLog(@"read:%@",[self CBRead:MY_CB_INDEX]);
        NSLog(@"write:%d",[self CBWrite:MY_CB_INDEX forResult:CB_PASS]);
        NSLog(@"read:%@",[self CBRead:MY_CB_INDEX]);
        NSLog(@"erase:%d",[self CBErase:MY_CB_INDEX]);
        NSLog(@"read:%@",[self CBRead:MY_CB_INDEX]);
        NSLog(@"fail count:%d",[self CBRead_Fail_count:MY_CB_INDEX]);
    }
}

-(void)CBErrorInfoToPDCA:(NSString *)test SubTest:(NSString *)subtest failMesg:(NSString *)mesg
{
    isPass=false;
    [testValue setString:@"0"];
    [testMessage setString:mesg];
    [testDisplayMessage setString:mesg];
    NSLog(@"CB_ErrorInfo ==>%@ %@ %@",test,subtest,mesg);
    
    BOOL replyResult = NO;
    // create a test specification for our test
    [puddings UUT_CreateTest];
    [puddings UUT_TestSpecSetTestName:[test UTF8String]];
    [puddings UUT_TestSpecSetSubTestName:[subtest UTF8String]];
    [puddings UUT_TestSpecSetValue:"0"];
    [puddings UUT_TestSpecSetLimits:"" Upper_Limits:""];
    [puddings UUT_TestSpecSetUnits:""];
    [puddings UUT_TestSpecSetPriority:0];
    [puddings UUT_TestSpecSetResult:TEST_FAIL1];
    [puddings UUT_TestSpecSetMessage:[mesg UTF8String]];
    replyResult = [puddings UUT_AddResult];
    
    if (!replyResult)   NSLog(@"%s",[puddings replyError]);
    [puddings UUT_CleanTest];
}

-(void)SetCB:(NSMutableArray *)args
{
    init_before_test
    
    if (![plist isAllowPudding])
    {
        isPass=TRUE;
        return;
    }
    
    if ([plist isAllowAuditMode])
    {
        isPass = true;
        [testValue setString:@"1"];
        [testDisplayMessage setString:@"Audit Mode"];
        return;
    }
    
    if ([MY_CB_INDEX isEqualToString:DefectCBIndex]) // for without control bits
    {
        isPass=TRUE;
        return;
    }
    
    ControlBits *controlBits = [self catchObj:args name:controlbits];
    
    if([plist checkIsAllPassForSetCB:my_thread_index])
    {
        if(![controlBits CBsToClearOnPass])
        {
            [testMessage setString:[controlBits testMessage]];
            [testDisplayMessage setString:testMessage];
            return;
        }
        if([controlBits SetCBsEnable])
        {
            //if (![self verifySameSN:args]) return;
            
            if ([self CBWrite:MY_CB_INDEX forResult:CB_PASS])
                isPass=true;
            else
            {
                [testMessage setString:@"CB Error(Setting Could not Set Pass CB):CBWrite PASS failed"];
                [testDisplayMessage setString:testMessage];
            }
        }
        else
        {
            isPass = TRUE;
            [testMessage setString:@"CB NOT Enable"];
            [testDisplayMessage setString:testMessage];
            return;
            
        }
    }
    else
    {
        if(![controlBits CBsToClearOnFail])
        {
            [testMessage setString:[controlBits testMessage]];
            [testDisplayMessage setString:testMessage];
            return;
        }
        if([controlBits SetCBsEnable])
        {
            //if (![self verifySameSN:args]) return;
            
            if ([self CBWrite:MY_CB_INDEX forResult:CB_FAIL])
                isPass=true;
            else
            {
                [testMessage setString:@"CB Error(Setting Could not Set Fail CB):CBWrite FAIL failed"];
                [testDisplayMessage setString:testMessage];
            }
        }
        else
        {
            isPass = TRUE;
            [testMessage setString:@"CB NOT Enable"];
            [testDisplayMessage setString:testMessage];
            return;
            
        }
    }
    
    if (isPass)
    {
        [testValue setString:@"1"];
        [testDisplayMessage setString:@"CBWrite successful"];
    }
}

-(BOOL)verifySameSN:(NSMutableArray *)args
{
    NSString *sn1=[self catchObj:args name:SN];
    NSString *sn2=@"";/*TODO: read sn from dut*/
    
    if (![sn1 isEqualToString:sn2])
    {
        NSString *mesg=[NSString stringWithFormat:@"Expected SN:%@ Read SN:%@ After commiting the FAIL for SN1,please also submit a FAIL result SN2",sn1,sn2];
        [self CBErrorInfoToPDCA:@"CB Error" SubTest:@"Unit SN Changed" failMesg:mesg];
        return FALSE;
    }
    return TRUE;
}

- (BOOL)CBWrite:(NSString *)atIndex forResult:(NSString *)result
{
    const short len=20;
    
    if ([[result uppercaseString] isEqualToString:CB_PASS])
    {
        unsigned char *nonce = [dev getNonce];
        
        NSString *str = [dev queryByCmd:[NSString stringWithFormat:@"cbwrite %@ pass\r",atIndex] strWaited:@">" retry:1 timeout:5];
        
        if (str == nil)
            return FALSE;
        
        unsigned char key[20] = {0};
        [Utility convertStrByPair:[SecretKeyTable objectForKey:MY_CB_INDEX] toCharArr:key];
        unsigned char *sha1 = [dev getSHA1:key andNonce:nonce];
        
        [dev writeToDeviceByBytes:sha1 length:len];
        sleep(1);
        str = [dev readFromDevice] ;
        
        if ([str rangeOfString:@"ERROR"].location != NSNotFound)
        {
            NSLog(@"write_pass ERROR message: %@",str);
            [self CBErrorInfoToPDCA:@"CB Error" SubTest:@"Could not set PASS CB" failMesg:@"Setting CB to PASS failed"];
            
            return FALSE;
        }
    }
    else
    {
        NSString *str = [dev queryByCmd:[NSString stringWithFormat:@"cbwrite %@ %@\r",atIndex,[result lowercaseString]] strWaited:@"OK" retry:1 timeout:5];
        if (str == nil)
            return FALSE;
    }
    
    NSLog(@"CB Write (ID:%@ Result:%@) OK!",atIndex,result);
    return TRUE;
}

- (NSString*)CBRead:(NSString *)atIndex
{
    NSString *str = [dev queryByCmd:[NSString stringWithFormat:@"cbread %@\r",atIndex] strWaited:ENDING_SYMBOL retry:1 timeout:3];
    
    if ([str length] > 0)
    {
        // <station> <state> <rel_fail_ct> <abs_fail_ct> <erase_ct> <test-time> <sw-version>
        NSMutableArray *msgArr = [RegxFunc regxByText:str textRegx:@"(0x\\w+) (\\w+) (\\d+) (\\d+) (\\d+) (\\S+)"];
        if ([msgArr count] > 0)
        {
            [msgArr setArray:[[msgArr objectAtIndex:0] componentsSeparatedByString:@" "]];
            
            if ([msgArr count] > 1)
            {
                NSString *cbResult =  [[msgArr objectAtIndex:1] uppercaseString];
                
                if ([cbResult rangeOfString:CB_PASS].location != NSNotFound)            return CB_PASS;
                else if ([cbResult rangeOfString:CB_INCOMPLETE].location != NSNotFound) return CB_INCOMPLETE;
                else if ([cbResult rangeOfString:CB_FAIL].location != NSNotFound)       return CB_FAIL;
                else if ([cbResult rangeOfString:CB_UNTESTED].location != NSNotFound)   return CB_UNTESTED;
            }
        }
        if ([[str uppercaseString] rangeOfString:CB_UNTESTED].location != NSNotFound)   return CB_UNTESTED;
    }
    return @"";
}


- (BOOL)CBErase:(NSString *)atIndex
{
    const short len=20;
    
    unsigned char *nonce = [dev getNonce];
    
    NSString *str = [dev queryByCmd:[NSString stringWithFormat:@"cberase %@\r",atIndex] strWaited:@">" retry:1 timeout:5];
    
    if (str == nil)
        return FALSE;
    
    unsigned char key[20] = {0};
    [Utility convertStrByPair:[SecretKeyTable objectForKey:MY_CB_INDEX] toCharArr:key];
    unsigned char *sha1 = [dev getSHA1:key andNonce:nonce];
    
    [dev writeToDeviceByBytes:sha1 length:len];
    sleep(1);
    str = [dev readFromDevice] ;
    
    if ([str rangeOfString:@"FAILED"].location != NSNotFound)
    {
        NSLog(@"Erase ERROR message: %@",str);
        return FALSE;
    }
    
    return TRUE;
}

- (int)CBRead_Fail_count:(NSString *)atIndex
{
    NSString *str = [dev queryByCmd:[NSString stringWithFormat:@"cbread %@\r",atIndex] strWaited:ENDING_SYMBOL retry:1 timeout:5];
    if(str != nil)
    {
        NSMutableArray* objs=[RegxFunc regxByGroup:str groupRegx:@" (\\d+) "];
        if([objs count]>0)
            return [[objs objectAtIndex:0] intValue];// this is relfails number
    }
    
    return DefectFailCount;
}

#pragma mark Change BootArg
-(int)writeCmd:(NSString*)cmd interval:(int)gap time:(int)sec
{
    NSDate *start=[NSDate dateWithTimeIntervalSinceNow:sec];
    while (1)
    {
        [dev writeToDevice:cmd];
        NSString *response=[dev readFromDevice];
        if (([response rangeOfString:@"login:"].location!=NSNotFound)||([response rangeOfString:@"root#"].location!=NSNotFound))
            return IOS_MODE;
        else if([response rangeOfString:@"\n]"].location!=NSNotFound)
            return IBOOT_MODE;
        else if([response rangeOfString:ENDING_SYMBOL].location!=NSNotFound)
            return DIAG_MODE;
        else if(![response isEqualToString:@""])
            start=[NSDate dateWithTimeIntervalSinceNow:sec];
        else
        {
            NSDate *now=[NSDate dateWithTimeIntervalSinceNow:0];
            if ([now compare:start] == NSOrderedDescending )
                return NO_ANSWER;
        }
        usleep(gap);
    }
    return NO_ANSWER;
}

-(void)changeBoot
{
    [dev writeToDevice:@"setenv bootdelay 2\r"];
    [dev writeToDevice:@"setenv boot-command fsboot\r"];
    [dev writeToDevice:@"setenv auto-boot false\r"];
    [dev writeToDevice:@"saveenv\r"];
    [dev writeToDevice:@"reboot\r"];
}

-(BOOL)EnterDiags
{
    int timeGap = 300000;
    
    while(1)
    {
        int status=[self writeCmd:@"\r" interval:300000 time:10];
        
        switch (status)
        {
            case NO_ANSWER:
                return NO;
                
            case IOS_MODE:
                NSLog(@"Entering IOS MODE");
                [dev writeToDevice:@"root\r"];
                [dev writeToDevice:@"alpine\r"];
                [dev writeToDevice:@"reboot\r"];
                sleep(3);
                [dev readFromDevice];
                continue;
                
            case IBOOT_MODE:
                NSLog(@"Entering IBOOT MODE");
                [dev writeToDevice:@"diags\r"];
                usleep(500000);
                [dev queryByCmd:@"diags\r" strWaited:[NSString stringWithFormat:@"] %@",ENDING_SYMBOL] retry:1 timeout:3];
                continue;
                
            case DIAG_MODE:
                NSLog(@"Entering DIAG MODE");
                return YES;
                
            default:
                break;
        }
        usleep(timeGap);
    }
    return NO;
}

#pragma mark MessageBox
-(void)displayMsg:(NSString *)text
{
    [self performSelectorOnMainThread:@selector(msgBox:) withObject:text waitUntilDone:YES];
}

-(void)msgBox:(NSString *)text
{
    confirm=FALSE;
    NSAlert *alert=[[NSAlert alloc] init];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
    [alert setMessageText:NSLocalizedString(@"Question:", nil) ];
    [alert setInformativeText:text];
    [alert setAlertStyle:0];
    [alert setIcon:[NSImage imageNamed:@"Qimg"]];
    long int result=[alert runModal];
    [alert release];
    if (result==NSAlertFirstButtonReturn)
        confirm= TRUE;
}
@end
