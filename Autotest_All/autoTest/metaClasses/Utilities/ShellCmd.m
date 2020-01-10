//
//  ShellCmd.m
//  excuteCmd
//
//  Created by TOM on 2014/8/18.
//  Copyright (c) 2014年 TOM. All rights reserved.
//

#import "ShellCmd.h"
@implementation ShellCmd
static NSString *changeDir;
static NSMutableString *consoleLog;
+(void)DEMO
{
    NSLog(@"[opt:%@]",[ShellCmd runBashCommand:@"cd ~"]);
    
    NSLog(@"[opt:%@]",[ShellCmd runShellScript:@"/Users/may/Desktop/testShellScript.sh"]);
    NSLog(@"[opt:%@]",[ShellCmd runExeAppByArg:@"/Users/may/Desktop/testShellScript.sh" arguments:[NSArray arrayWithObjects:@[],nil]]);
    NSLog(@"[opt:%@]",[ShellCmd runExeAppByArg:@"/Users/may/Desktop/testShellScript.sh" arguments:[NSArray arrayWithObjects:@"A1",@"A2",@"A3",nil]]);
    
    ShellCmd *cmd = [[ShellCmd alloc] init];
    [cmd runBashCommand_launch:@"cd ~"];
    NSLog(@"[opt:%@]",[cmd runBashCommand_result]);
    [cmd release];
    
    ShellCmd *script = [[ShellCmd alloc] init];
    [script runShellScript_launch:@"/Users/may/Desktop/testShellScript.sh"];
    [script runShellScript_stdin:@"1\n"];
    NSLog(@"[opt:%@]",[script runShellScript_result]);
    [script release];
    
    ShellCmd *exe1 = [[ShellCmd alloc] init];
    [exe1 runExeAppByArg_launch:@"/Users/may/Desktop/testShellScript.sh" arguments:[NSArray arrayWithObjects:@[],nil]];
    NSLog(@"[opt:%@]",[exe1 runExeAppByArg_result]);
    [exe1 release];
    
    ShellCmd *exe2 = [[ShellCmd alloc] init];
    [exe2 runExeAppByArg_launch:@"/Users/may/Desktop/testShellScript.sh" arguments:[NSArray arrayWithObjects:@"A1",@"A2",@"A3",nil]];
    NSLog(@"[opt:%@]",[exe2 runExeAppByArg_result]);
    [exe2 release];
}

+(NSString*)saveShellCmdLog:(NSString *)sn// file name : time+sn.txt
{
    //chack folder is exist if not creat
    NSFileManager *fileMgr=[[[NSFileManager alloc]init] autorelease];
    NSString *IACHostLogsFolderPath = @"/vault/IACHostLogs";
    if (![fileMgr fileExistsAtPath:IACHostLogsFolderPath])
        [fileMgr createDirectoryAtPath:IACHostLogsFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *devLogsFolderPath = [NSString stringWithFormat:@"%@/Shell_Text",IACHostLogsFolderPath];
    if (![fileMgr fileExistsAtPath:devLogsFolderPath])
        [fileMgr createDirectoryAtPath:devLogsFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSDate *localDateTime=[NSDate date];
    NSDateFormatter *dateTimeFormat=[[[NSDateFormatter alloc]init] autorelease];
    dateTimeFormat.dateFormat=@"yyyy-MM-dd-HH-mm-ss";
    
    NSString *dateStr=[dateTimeFormat stringFromDate:localDateTime];
    
    NSString *file=[NSString stringWithFormat:@"%@/%@(%@).txt",devLogsFolderPath,dateStr,sn];
    [consoleLog writeToFile:file atomically:NO encoding:NSASCIIStringEncoding error:nil];
    [consoleLog release];
    consoleLog=nil;
    return file;
}

+(void)recording:(NSString*)input opt:(NSString*)output
{
    if (consoleLog!=nil)
        [consoleLog appendString:[NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"\nSEND:%@\n",input],output]];
    else
        consoleLog=[[NSMutableString alloc] initWithFormat:@"%@%@",[NSString stringWithFormat:@"\nSEND:%@\n",input],output];
}

+(NSString*)runBashCommand:(NSString*)cmd
{
    @try
    {
        if ([cmd rangeOfString:@"cd"].location!=NSNotFound && [cmd rangeOfString:@"&& pwd"].location==NSNotFound)
        {
            cmd=[NSString stringWithFormat:@"%@ && pwd",cmd];
        }
        
        NSTask *task=[[NSTask alloc] init];
        
        if ([changeDir length]>0)
        {
            [task setCurrentDirectoryPath:changeDir];
        }
        
        [task setLaunchPath:@"/bin/bash"];
        [task setArguments:[NSArray arrayWithObjects:@"-c", cmd, nil]];
        
        NSPipe *pipe=[NSPipe pipe];
        
        //The magic line that keeps your log where it belongs
        [task setStandardInput:[NSPipe pipe]];
        [task setStandardOutput: pipe];
        [task setStandardError: pipe];
        
        NSFileHandle *file=[pipe fileHandleForReading];
        [task launch];
        [task waitUntilExit];
        
        NSString *output=[[[NSString alloc]initWithData:[file readDataToEndOfFile] encoding:NSASCIIStringEncoding] autorelease];
        
        if ([cmd rangeOfString:@"cd"].location!=NSNotFound)
        {
            changeDir=[[output stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] copy];
        }
        
        [task release];
        [self recording:cmd opt:output];
        return output;
    }
    @catch(NSException *e)
    {
        [self recording:cmd opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}

+(NSString*)runShellScript:(NSString*)path
{
    @try
    {
        NSTask *task=[[NSTask alloc] init];
        [task setLaunchPath:@"/bin/bash"];
        
        [task setArguments:[NSArray arrayWithObjects:path, nil]];
        
        NSPipe *pipe=[NSPipe pipe];
        
        //The magic line that keeps your log where it belongs
        [task setStandardInput:[NSPipe pipe]];
        [task setStandardOutput: pipe];
        [task setStandardError: pipe];
        
        NSFileHandle *file=[pipe fileHandleForReading];
        [task launch];
        [task waitUntilExit];
        
        NSString *output=[[[NSString alloc] initWithData:[file readDataToEndOfFile] encoding: NSUTF8StringEncoding] autorelease];
        
        [task release];
        [self recording:path opt:output];
        return output;
    }
    @catch(NSException *e)
    {
        [self recording:path opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}

+(NSString*)runExeAppByArg:(NSString*)path arguments:(NSArray*)args
{
    @try
    {
        NSTask *task=[[NSTask alloc] init];
        [task setLaunchPath:path];
        [task setArguments:args];
        NSPipe *pipe=[NSPipe pipe];
        
        //The magic line that keeps your log where it belongs
        [task setStandardInput:[NSPipe pipe]];
        [task setStandardOutput: pipe];
        [task setStandardError: pipe];
        
        NSFileHandle *file=[pipe fileHandleForReading];
        [task launch];
        [task waitUntilExit];
        
        NSString *output=[[[NSString alloc] initWithData:[file readDataToEndOfFile] encoding: NSUTF8StringEncoding] autorelease];
        [task release];
        [self recording:path opt:output];
        return output;
    }
    @catch(NSException *e)
    {
        [self recording:path opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}

+(NSString*)runExeAppByArgAndDirectory:(NSString*)path arguments:(NSArray*)args directory:(NSString*)dirctory
{
    @try
    {
        NSTask *task=[[NSTask alloc] init];
        [task setLaunchPath:path];
        [task setArguments:args];
        NSPipe *pipe=[NSPipe pipe];
        
        //The magic line that keeps your log where it belongs
        [task setCurrentDirectoryPath:dirctory];
        [task setStandardInput:[NSPipe pipe]];
        [task setStandardOutput: pipe];
        [task setStandardError: pipe];
        
        NSFileHandle *file=[pipe fileHandleForReading];
        [task launch];
        
        NSString *output=[[[NSString alloc] initWithData:[file readDataToEndOfFile] encoding: NSUTF8StringEncoding] autorelease];
        [task release];
        [self recording:path opt:output];
        return output;
    }
    @catch(NSException *e)
    {
        [self recording:path opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}





//------------------------------below is instance method-------------------------------
-(id)init
{
    if(self=[super init])
    {
        sendCMD = [[NSMutableString alloc] init];
        my_task = [[NSTask alloc] init];
        logStr = [[NSMutableString alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [sendCMD release];
    [my_task release];
    [logStr release];
    [super dealloc];
}

-(NSString*)runBashCommand_launch:(NSString*)cmd
{
    @try
    {
        isRecData = NO;
        [sendCMD setString:cmd];
        
        if ([cmd rangeOfString:@"cd"].location!=NSNotFound && [cmd rangeOfString:@"&& pwd"].location==NSNotFound)
        {
            cmd=[NSString stringWithFormat:@"%@ && pwd",cmd];
        }
        
        if ([changeDir length]>0)
        {
            [my_task setCurrentDirectoryPath:changeDir];
        }
        
        [my_task setLaunchPath:@"/bin/bash"];
        [my_task setArguments:[NSArray arrayWithObjects:@"-c", cmd, nil]];
        
        NSPipe *pipe=[NSPipe pipe];
        
        //The magic line that keeps your log where it belongs
        [my_task setStandardInput:[NSPipe pipe]];
        [my_task setStandardOutput: pipe];
        [my_task setStandardError: pipe];
        
        rec_file=[pipe fileHandleForReading];
        [my_task launch];
        
        isRecData = YES;
        return @"OK";
    }
    @catch(NSException *e)
    {
        [self recordingNew:cmd opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}

-(NSString*)runBashCommand_launch:(NSString*)cmd needInputNumber:(NSArray*)selection
{
    @try
    {
        isRecData = NO;
        [sendCMD setString:cmd];
        
        if ([cmd rangeOfString:@"cd"].location!=NSNotFound && [cmd rangeOfString:@"&& pwd"].location==NSNotFound)
        {
            cmd=[NSString stringWithFormat:@"%@ && pwd",cmd];
        }
        
        if ([changeDir length]>0)
        {
            [my_task setCurrentDirectoryPath:changeDir];
        }
        
        [my_task setLaunchPath:@"/bin/bash"];
        [my_task setArguments:[NSArray arrayWithObjects:@"-c", cmd, nil]];
        
        NSPipe *pipe=[NSPipe pipe];
        
        //The magic line that keeps your log where it belongs
        [my_task setStandardInput:[NSPipe pipe]];
        [my_task setStandardOutput: pipe];
        [my_task setStandardError: pipe];
        
        rec_file=[pipe fileHandleForReading];
        [my_task launch];
        
        if (selection != nil) {
            for (int i = 0; i < [selection count]; i++) {
                [self runShellScript_stdin:[selection objectAtIndex:i]];
            }
        }
        
        isRecData = YES;
        return @"OK";
    }
    @catch(NSException *e)
    {
        [self recordingNew:cmd opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}


-(NSString *)runBashCommand_result
{
    @try
    {
        if (isRecData)
        {
            NSString *output=[[[NSString alloc]initWithData:[rec_file readDataToEndOfFile] encoding:NSASCIIStringEncoding] autorelease];
            
            if ([sendCMD rangeOfString:@"cd"].location!=NSNotFound)
            {
                changeDir=[[output stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] copy];
            }
            
            [self recordingNew:sendCMD opt:output];
            return output;
        }
        return @"Receive data is empty";
    }
    @catch (NSException *e)
    {
        [self recordingNew:sendCMD opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}



-(NSString*)runShellScript_launch:(NSString*)path
{
    @try
    {
        isRecData = NO;
        [sendCMD setString:path];
        
        [my_task setLaunchPath:@"/bin/bash"];
        
        [my_task setArguments:[NSArray arrayWithObjects:path, nil]];
        
        NSPipe *pipe=[NSPipe pipe];
        
        //The magic line that keeps your log where it belongs
        [my_task setStandardInput:[NSPipe pipe]];
        [my_task setStandardOutput: pipe];
        [my_task setStandardError: pipe];
        
        rec_file = [pipe fileHandleForReading];
        [my_task launch];
        
        isRecData = YES;
        return @"OK";
    }
    @catch(NSException *e)
    {
        [self recordingNew:path opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}

-(NSString *)runShellScript_result
{
    @try
    {
        if (isRecData)
        {
            NSString *output=[[[NSString alloc] initWithData:[rec_file readDataToEndOfFile] encoding: NSUTF8StringEncoding] autorelease];
            [self recordingNew:sendCMD opt:output];
            return output;
        }
        return @"Receive data is empty";
    }
    @catch (NSException *e)
    {
        [self recordingNew:sendCMD opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}

-(NSString *)runExeAppByArg_launch:(NSString *)path arguments:(NSArray *)args
{
    @try
    {
        isRecData = NO;
        [sendCMD setString:path];
        
        [my_task setLaunchPath:path];
        [my_task setArguments:args];
        NSPipe *pipe=[NSPipe pipe];
        
        //The magic line that keeps your log where it belongs
        [my_task setStandardInput:[NSPipe pipe]];
        [my_task setStandardOutput: pipe];
        [my_task setStandardError: pipe];
        
        rec_file = [pipe fileHandleForReading];
        [my_task launch];
        
        isRecData = YES;
        return @"OK";
    }
    @catch(NSException *e)
    {
        [self recordingNew:path opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}

-(NSString *)runExeAppByArg_result
{
    @try
    {
        if (isRecData)
        {
            NSString *output=[[[NSString alloc] initWithData:[rec_file readDataToEndOfFile] encoding: NSUTF8StringEncoding] autorelease];
            [self recordingNew:sendCMD opt:output];
            [rec_file closeFile];
            return output;
        }
        return @"Receive data is empty";
    }
    @catch (NSException *e)
    {
        [self recordingNew:sendCMD opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}

-(NSString *)runShellScript_stdin:(NSString*)input
{
    @try
    {
        NSData *data = [input dataUsingEncoding:NSASCIIStringEncoding];
        [[[my_task standardInput] fileHandleForWriting] writeData:data];
    }
    @catch (NSException *e)
    {
        [self recordingNew:input opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}

-(NSString*)saveShellCmdLogNew:(NSString *)sn// file name : time+sn.txt
{
    //chack folder is exist if not creat
    NSFileManager *fileMgr=[[[NSFileManager alloc]init] autorelease];
    NSString *IACHostLogsFolderPath = @"/vault/IACHostLogs";
    if (![fileMgr fileExistsAtPath:IACHostLogsFolderPath])
        [fileMgr createDirectoryAtPath:IACHostLogsFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *devLogsFolderPath = [NSString stringWithFormat:@"%@/Shell_Text",IACHostLogsFolderPath];
    if (![fileMgr fileExistsAtPath:devLogsFolderPath])
        [fileMgr createDirectoryAtPath:devLogsFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSDate *localDateTime=[NSDate date];
    NSDateFormatter *dateTimeFormat=[[[NSDateFormatter alloc]init] autorelease];
    dateTimeFormat.dateFormat=@"yyyy-MM-dd-HH-mm-ss";
    
    NSString *dateStr=[dateTimeFormat stringFromDate:localDateTime];
    
    NSString *file=[NSString stringWithFormat:@"%@/%@(%@).txt",devLogsFolderPath,dateStr,sn];
    [logStr writeToFile:file atomically:NO encoding:NSASCIIStringEncoding error:nil];
    [logStr setString:@""];
    return file;
}

-(void)recordingNew:(NSString*)input opt:(NSString*)output
{
    [logStr appendString:[NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"\nSEND:%@\n",input],output]];
}

-(NSString*)runBashCommandNew:(NSString*)cmd
{
    @try
    {
        if ([cmd rangeOfString:@"cd"].location!=NSNotFound && [cmd rangeOfString:@"&& pwd"].location==NSNotFound)
        {
            cmd=[NSString stringWithFormat:@"%@ && pwd",cmd];
        }
        
        NSTask *task=[[NSTask alloc] init];
        
        if ([changeDir length]>0)
        {
            [task setCurrentDirectoryPath:changeDir];
        }
        
        [task setLaunchPath:@"/bin/bash"];
        [task setArguments:[NSArray arrayWithObjects:@"-c", cmd, nil]];
        
        NSPipe *pipe=[NSPipe pipe];
        
        //The magic line that keeps your log where it belongs
        [task setStandardInput:[NSPipe pipe]];
        [task setStandardOutput: pipe];
        [task setStandardError: pipe];
        
        NSFileHandle *file=[pipe fileHandleForReading];
        [task launch];
        [task waitUntilExit];
        
        NSString *output=[[[NSString alloc]initWithData:[file readDataToEndOfFile] encoding:NSASCIIStringEncoding] autorelease];
        
        if ([cmd rangeOfString:@"cd"].location!=NSNotFound)
        {
            changeDir=[[output stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] copy];
        }
        
        [task release];
        [self recordingNew:cmd opt:output];
        return output;
    }
    @catch(NSException *e)
    {
        [self recordingNew:cmd opt:[NSString stringWithFormat:@"%@",e]];
        return [NSString stringWithFormat:@"%@",e];
    }
}

-(void)TerminateShell
{
    if(my_task.running)
        [my_task terminate];
}

-(void)KillProcess
{
    int tid = [my_task processIdentifier];
    if(tid!=0)
    {
        NSString *killTask = [NSString stringWithFormat:@"/bin/kill -KILL %i", tid];
        system([killTask cStringUsingEncoding:NSASCIIStringEncoding]);
    }
}
@end
