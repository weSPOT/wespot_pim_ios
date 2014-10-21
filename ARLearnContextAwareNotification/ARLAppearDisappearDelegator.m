//
//  ARLAppearDisappearDelegator.m
//  ARLearn
//
//  Created by Stefaan Ternier on 8/7/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLAppearDisappearDelegator.h"

@implementation ARLAppearDisappearDelegator

+ (ARLAppearDisappearDelegator *) sharedSingleton {
    static ARLAppearDisappearDelegator *sharedSingleton;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedSingleton = [[ARLAppearDisappearDelegator alloc] init];
    });
    return sharedSingleton;
}

- (void) setTimer: (NSDate *) fireDate {
    DLog(@"Timer is scheduled to go off at %@ ", [fireDate description]);
    
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:fireDate
                                              interval:0.5
                                                target:self
                                              selector:@selector(fireTimer)
                                              userInfo:nil
                                               repeats:NO];

//  [timer fireDate]
    dispatch_async(dispatch_get_main_queue(), ^{
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    });
}

- (void) fireTimer {
    DLog(@"timer went off: ");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
        [CurrentItemVisibility updateVisibility:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentRun"] withManagedContext:appDelegate.managedObjectContext];
        
        [INQLog SaveNLog:appDelegate.managedObjectContext];
        
       //WARNING: Warning MAGIC NUMBER !!
       for (CurrentItemVisibility* vis in [CurrentItemVisibility retrieveVisibleFor: [NSNumber numberWithLongLong:3457078]withManagedContext: appDelegate.managedObjectContext]) {
            DLog(@"Visibility Statement %@", vis.item.name);
        }
    });
}

@end
