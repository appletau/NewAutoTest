//
//  ValidatorPW.m
//  autoTest
//
//  Created by May on 11/30/15.
//  Copyright (c) 2015 TOM. All rights reserved.
//

#import "ValidatorPW.h"

@implementation ValidatorPW

- (id)init
{
    self = [super init];
    if (self) {
        passString = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [passString release];
    [super dealloc];
}

-(BOOL)checkPassString:(NSString *)errorMsg
{
    for (NSString *temp in passString)
    {
        if ([temp isEqualToString:errorMsg])
            return TRUE;
    }
    return FALSE;
}

-(BOOL)checkPasswordMsg:(NSString *)msg checkPassword:(NSString*)password changeBGcolor:(BOOL)isBGChange
{
    BOOL isCorrectPW=TRUE;
    
    //if ([msg rangeOfString:@"UNIT OUT OF PROCESS"].location != NSNotFound && [self checkPassString:msg]) return FALSE;

    NSAlert *alert=[[[NSAlert alloc] init] autorelease];
    [alert setInformativeText:msg];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Warning: Please input the password"];
    [alert setIcon:[NSImage imageNamed:@"lock"]];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    NSSecureTextField *inputText = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0,0,200, 25)];
    [alert setAccessoryView:inputText];
    
    NSTimer *timer;
    if (isBGChange)
    {
        [[alert window] setBackgroundColor:[NSColor yellowColor]];
        timer=[NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(twinkleEvent:) userInfo:alert repeats:YES];
        [self performSelectorInBackground:@selector(startTwinkle:) withObject:timer];
    }

    isCorrectPW=FALSE;
    do
    {
        if ([alert runModal]==NSAlertFirstButtonReturn)
        {
            if ([[inputText stringValue] isEqualToString:password])
            {
                [passString addObject:msg];
                isCorrectPW=TRUE;
            }
        }
        else
        {
            NSLog(@"cancel");
            break;
        }
        [inputText setStringValue:@""];
    }while (!isCorrectPW);
    
    if (isBGChange)
        [self stopTwinkle:timer];
    [inputText release];
    
    
    return isCorrectPW;
}

-(void)stopTwinkle:(NSTimer *)timer
{
    [timer invalidate];
    CFRunLoopStop([runLoop getCFRunLoop]);
}

- (void)startTwinkle:(NSTimer*)timer
{
    if (![NSThread isMainThread])
    {
        runLoop=[NSRunLoop currentRunLoop];
        [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

- (void)twinkleEvent:(NSTimer *)arg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (arg.valid == 1)  // 1 for action, 0 for close
        {
            NSAlert *alert=arg.userInfo;
            if(isChange)
            {
                [[alert window] setBackgroundColor:[NSColor yellowColor]];
                isChange = false;
            }
            else
            {
                [[alert window] setBackgroundColor:[NSColor redColor]];
                isChange = true;
            }
        }
    });
}


-(NSString *)CheckSNMessage:(NSString *)mesg SN_lenToCheck:(const int)snLen
{

    NSAlert *alert=[[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:mesg];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    NSTextField *inputText = [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,200, 25)] autorelease];
    [alert setAccessoryView:inputText];
    
    do
    {
        if ([alert runModal]==NSAlertFirstButtonReturn)
        {
            if ([[inputText stringValue] length]==snLen)
            {
                return [inputText stringValue];
            }
            [inputText setStringValue:@""];
        }
    }while (1);
}

-(NSString *)CheckUserMessage:(NSString *)msg
{
    NSAlert *alert=[[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:msg];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    NSTextField *inputText = [[[NSTextField alloc] initWithFrame:NSMakeRect(0,0,200, 25)] autorelease];
    [alert setAccessoryView:inputText];
    
    do
    {
        if ([alert runModal]==NSAlertFirstButtonReturn)
        {
            return [inputText stringValue];
        }
    }while (1);
}

@end
