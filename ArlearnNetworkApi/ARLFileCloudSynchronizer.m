//
//  ARLFileCloudSynchronizer.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/16/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLFileCloudSynchronizer.h"

@implementation ARLFileCloudSynchronizer

@synthesize context = _context;

@synthesize syncGeneralItems = _syncGeneralItems;
@synthesize syncResponses = _syncResponses;

+ (void) syncGeneralItems: (NSManagedObjectContext*) context {
    NSLog(@"[%s]", __func__);
    
    ARLFileCloudSynchronizer* synchronizer = [[ARLFileCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncGeneralItems = YES;
    
    [synchronizer sync];
}

+ (void) syncResponseData: (NSManagedObjectContext*) context {
    NSLog(@"[%s]", __func__);
    
    ARLFileCloudSynchronizer* synchronizer = [[ARLFileCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncResponses = YES;
    
    [synchronizer sync];
}

- (void) createContext: (NSManagedObjectContext*) mainContext {
    self.parentContext = mainContext;
    
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.context.parentContext = mainContext;
}

- (void) sync {
    [self.context performBlock:^{
        [self asyncExecution];
    }];
}

- (void) asyncExecution {
    mach_port_t machTID = pthread_mach_thread_np(pthread_self());
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Checking Lock", ARLAppDelegate.theLock);
    
    [ARLAppDelegate.theLock lock];
    
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Passed Lock", ARLAppDelegate.theLock);
    
    NSLog(@"\r\n[%s 0x%x]\r\n*******************************************\r\nStart of File Synchronisation", __func__, machTID);

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    while (YES) {
        
        if (self.syncGeneralItems) {
            [self downloadGeneralItems];
        } else if (self.syncResponses) {
            [self downloadResponses];
        } else {
            [self saveContext];
            break;
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [ARLAppDelegate.theLock unlock];
    
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Exit Lock", ARLAppDelegate.theLock);
    
    NSLog(@"\r\n[%s 0x%x] End of File Synchronisation\r\n*******************************************", __func__, machTID);
}

/*!
 *  Save the Core Data Context.
 *
 *  See http://www.cocoanetics.com/2012/07/multi-context-coredata/
 *
 *  Runs on a separate thread in the background.
 */
- (void)saveContext
{
    NSError *error = nil;
    
    if (self.context) {
        if ([self.context hasChanges]){
            if (![self.context save:&error]) {
                NSLog(@"[%s] Unresolved error %@, %@", __func__, error, [error userInfo]);
                abort();
            }
            
//          NSLog(@"[%s] save context completed", __func__);
            [self.parentContext performBlock:^{
                NSError *error = nil;
                if (![self.parentContext save:&error]) {abort();}
            }];
            
        }
//      NSLog(@"[%s] save parent context completed", __func__);
        
    }
//  NSLog(@"[%s] save completed", __func__);
}

- (void) downloadGeneralItems {
    for (GeneralItemData* giData in [GeneralItemData getUnsyncedData:self.context]) {
//        NSLog(@"[%s] gidata url=%@ replicated=%@ error=%@", __func__, giData.url, giData.replicated, giData.error);
        NSURL  *url = [NSURL URLWithString:giData.url];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if (urlData){
            giData.data = urlData;
            giData.replicated = [NSNumber numberWithBool:YES];
        } else {
            NSLog(@"[%s] Could not fetch url", __func__);
        }
        
        [self saveContext];
    }
    
    self.syncGeneralItems=NO;
}

- (void) downloadResponses {
    for (Response* response in [Response getReponsesWithoutMedia:self.context]) {
//        NSLog(@"[%s] response url=%@", __func__, response.fileName);
        NSURL  *url = [NSURL URLWithString:response.fileName];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if (urlData){
            response.data = urlData;
            // giData.replicated = [NSNumber numberWithBool:YES];
        } else {
            NSLog(@"[%s] Could not fetch url", __func__);
        }
        
        [self saveContext];
    }
    
    self.syncResponses=NO;
}

@end
