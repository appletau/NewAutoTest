//
//  ThreadSync.h
//  autoTest
//
//  Created by 許智偉 on 15/09/2017.
//  Copyright © 2017 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
enum Status
{
    Skiped=-1,NotYet_PassThru=0,Passthru=1
};
@interface ThreadSync : NSObject
{
    NSMutableArray *SyncPointOnTC;
    NSMutableArray *SyncPoint1;
    NSMutableArray *SyncPoint2;
    NSMutableArray *SyncPoint3;
    NSMutableArray *SyncPoint4;
}
@property(readonly)NSMutableArray *SyncPointOnTC;
@property(readonly)NSMutableArray *SyncPoint1;
@property(readonly)NSMutableArray *SyncPoint2;
@property(readonly)NSMutableArray *SyncPoint3;
@property(readonly)NSMutableArray *SyncPoint4;
-(void)Reset;
-(void)FillinStatus:(int)status forThread:(int)thread_index;
-(BOOL)CheckSyncPointOnUI;
-(BOOL)CheckSyncPoint1;
-(BOOL)CheckSyncPoint2;
-(BOOL)CheckSyncPoint3;
-(BOOL)CheckSyncPoint4;
-(NSString *)Display;
-(void)SetSyncPointOnTC:(int)status forThread:(int)thread_index;
-(void)SetSyncPoint1:(int)status forThread:(int)thread_index;
-(void)SetSyncPoint2:(int)status forThread:(int)thread_index;
-(void)SetSyncPoint3:(int)status forThread:(int)thread_index;
-(void)SetSyncPoint4:(int)status forThread:(int)thread_index;
@end
