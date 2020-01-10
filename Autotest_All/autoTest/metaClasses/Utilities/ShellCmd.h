//
//  ShellCmd.h
//  ;;
//
//  Created by TOM on 2014/8/18.
//  Copyright (c) 2014年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShellCmd : NSObject
{
    NSFileHandle *rec_file;
    NSMutableString *sendCMD;
    BOOL isRecData;
    NSTask *my_task;
    NSMutableString *logStr;
}

+(void)DEMO;
+(NSString*)runBashCommand:(NSString*)cmd;
+(NSString*)runShellScript:(NSString*)path;
+(NSString*)runExeAppByArg:(NSString*)path arguments:(NSArray*)args;
+(NSString*)runExeAppByArgAndDirectory:(NSString*)path arguments:(NSArray*)args directory:(NSString*)dirctory;
+(NSString*)saveShellCmdLog:(NSString *)sn;

-(NSString*)runBashCommand_launch:(NSString*)cmd;
-(NSString*)runBashCommand_launch:(NSString*)cmd needInputNumber:(NSArray*)selection;
-(NSString *)runBashCommand_result;
-(NSString*)runShellScript_launch:(NSString*)path;
-(NSString *)runShellScript_result;
-(NSString *)runExeAppByArg_launch:(NSString *)path arguments:(NSArray *)args;
-(NSString *)runExeAppByArg_result;
-(NSString *)runShellScript_stdin:(NSString*)input;

-(NSString*)saveShellCmdLogNew:(NSString *)sn;
-(void)recordingNew:(NSString*)input opt:(NSString*)output;
-(NSString*)runBashCommandNew:(NSString*)cmd;

-(void)TerminateShell;
-(void)KillProcess;
@end
