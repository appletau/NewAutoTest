//
//  ThreadSync.m
//  autoTest
//
//  Created by 許智偉 on 15/09/2017.
//  Copyright © 2017 TOM. All rights reserved.
//

#import "ThreadSync.h"

@implementation ThreadSync
@synthesize SyncPointOnTC;
@synthesize SyncPoint1;
@synthesize SyncPoint2;
@synthesize SyncPoint3;
@synthesize SyncPoint4;

-(id)init
{
    if (self=[super init])
    {
        SyncPointOnTC=[[NSMutableArray alloc] initWithObjects:@"useless",[NSNumber numberWithInt:Skiped],[NSNumber numberWithInt:Skiped],[NSNumber numberWithInt:Skiped],[NSNumber numberWithInt:Skiped], nil];
        SyncPoint1=[[NSMutableArray alloc] initWithObjects:@"useless",[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru], nil];
        SyncPoint2=[[NSMutableArray alloc] initWithObjects:@"useless",[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru], nil];
        SyncPoint3=[[NSMutableArray alloc] initWithObjects:@"useless",[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru], nil];
        SyncPoint4=[[NSMutableArray alloc] initWithObjects:@"useless",[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru],[NSNumber numberWithInt:NotYet_PassThru], nil];
    }
    return self;
}

-(void)dealloc
{
    [SyncPointOnTC release];
    [SyncPoint1 release];
    [SyncPoint2 release];
    [SyncPoint3 release];
    [SyncPoint4 release];
    [super dealloc];
}

-(void)Reset
{
    @synchronized (self)
    {
        for(int i=1;i<=4;i++)
        {
            SyncPointOnTC[i]=[NSNumber numberWithInt:Skiped];
            SyncPoint1[i]=[NSNumber numberWithInt:NotYet_PassThru];
            SyncPoint2[i]=[NSNumber numberWithInt:NotYet_PassThru];
            SyncPoint3[i]=[NSNumber numberWithInt:NotYet_PassThru];
            SyncPoint4[i]=[NSNumber numberWithInt:NotYet_PassThru];
        }
    }
}
-(void)FillinStatus:(int)status forThread:(int)thread_index
{
    @synchronized (self)
    {
        SyncPointOnTC[thread_index]=[NSNumber numberWithInt:status];
        SyncPoint1[thread_index]=[NSNumber numberWithInt:status];
        SyncPoint2[thread_index]=[NSNumber numberWithInt:status];
        SyncPoint3[thread_index]=[NSNumber numberWithInt:status];
        SyncPoint4[thread_index]=[NSNumber numberWithInt:status];
    }
}
-(BOOL)CheckSyncPointOnUI
{
    usleep(10000);
    for(int i=1;i<=4;i++)
    {
        if([SyncPointOnTC[i] intValue]==NotYet_PassThru)
            return NO;
    }
    return YES;
}
-(BOOL)CheckSyncPoint1
{
    usleep(10000);
    for(int i=1;i<=4;i++)
    {
        if([SyncPoint1[i] intValue]==NotYet_PassThru)
            return NO;
    }
    return YES;
}
-(BOOL)CheckSyncPoint2
{
    usleep(10000);
    for(int i=1;i<=4;i++)
    {
        if([SyncPoint2[i] intValue]==NotYet_PassThru)
            return NO;
    }
    return YES;
}
-(BOOL)CheckSyncPoint3
{
    usleep(10000);
    for(int i=1;i<=4;i++)
    {
        if([SyncPoint3[i] intValue]==NotYet_PassThru)
            return NO;
    }
    return YES;
}
-(BOOL)CheckSyncPoint4
{
    usleep(10000);
    for(int i=1;i<=4;i++)
    {
        if([SyncPoint4[i] intValue]==NotYet_PassThru)
            return NO;
    }
    return YES;
}
-(void)SetSyncPointOnTC:(int)status forThread:(int)thread_index
{
    @synchronized (self)
    {
        SyncPointOnTC[thread_index]=[NSNumber numberWithInt:status];
    }
    //NSLog(@"set BeforeTdm flag to %d on thread%d\n%@",status,thread_index,[self Display]);
}
-(void)SetSyncPoint1:(int)status forThread:(int)thread_index
{
    @synchronized (self)
    {
        SyncPoint1[thread_index]=[NSNumber numberWithInt:status];
    }
    //NSLog(@"set BeforeTdm flag to %d on thread%d\n%@",status,thread_index,[self Display]);
}
-(void)SetSyncPoint2:(int)status forThread:(int)thread_index
{
    @synchronized (self)
    {
        SyncPoint2[thread_index]=[NSNumber numberWithInt:status];
    }
    //NSLog(@"set runTdmCounter flag to %d on thread%d\n%@",status,thread_index,[self Display]);
}
-(void)SetSyncPoint3:(int)status forThread:(int)thread_index
{
    @synchronized (self)
    {
        SyncPoint3[thread_index]=[NSNumber numberWithInt:status];
    }
    //NSLog(@"set audioCounter flag to %d on thread%d\n%@",status,thread_index,[self Display]);
}
-(void)SetSyncPoint4:(int)status forThread:(int)thread_index
{
    @synchronized (self)
    {
        SyncPoint4[thread_index]=[NSNumber numberWithInt:status];
    }
    //NSLog(@"set powerCounter flag to %d on thread%d\n%@",status,thread_index,[self Display]);
}
-(NSString *)Display
{
    NSMutableString *str=[NSMutableString stringWithString:@"\nSyncPointOnTC:"];
    for(int i=1;i<=4;i++)
        [str appendFormat:@"%d,",[SyncPointOnTC[i] intValue]];
    [str appendString:@"\nSyncPoint1:"];
    for(int i=1;i<=4;i++)
        [str appendFormat:@"%d,",[SyncPoint1[i] intValue]];
    [str appendString:@"\nSyncPoint2:"];
    for(int i=1;i<=4;i++)
        [str appendFormat:@"%d,",[SyncPoint2[i] intValue]];
    [str appendString:@"\nSyncPoint3:"];
    for(int i=1;i<=4;i++)
        [str appendFormat:@"%d,",[SyncPoint3[i] intValue]];
    [str appendString:@"\nSyncPoint4:"];
    for(int i=1;i<=4;i++)
        [str appendFormat:@"%d,",[SyncPoint4[i] intValue]];
    [str appendFormat:@"\nSkiped=%d,NotYet_PassThru=%d,Passthru=%d\n",Skiped,NotYet_PassThru,Passthru];
    return str;
}

/*
below is a demo code in Function.m

-(void)Item1:(NSMutableArray *)args
{
    init_before_test
 
    TODO: add real test code here
    [threadSyncStatus SetSyncPoint1:Passthru forThread:my_thread_index];
}

Item2 will wait until all thread's Item1 Done
 
-(void)Item2:(NSMutableArray *)args
{
    init_before_test
    
    while(![threadSyncStatus CheckSyncPoint1]);
    TODO: add real test code here
}
 
Notice:
1.must do Reset when start all test and then Check sn, if sn is illegal then you have to set skiped state by FillinStatus method
2.Pudding_checkAMIOK in Function.m must set skiped stae by FillinStatus method in case of UOP happened etc.
*/



@end
