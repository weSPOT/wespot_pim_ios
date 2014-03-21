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
    NSLog(@"\r\n[%s]\r\n*******************************************\r\nStart of synchronisation", __func__);
    while (YES) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [self downloadGeneralItems];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        // Already done in downloadGeneralItems, but added dor symmetry with other asyncExecution methods.
        [self saveContext];
        
        break;
    }
    NSLog(@"\r\n[%s] End of synchronisation\r\n*******************************************\r\n", __func__);
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
            
            NSLog(@"[%s] save context completed", __func__);
            [self.parentContext performBlock:^{
                NSError *error = nil;
                if (![self.parentContext save:&error]) {abort();}
            }];
            
        }
        NSLog(@"[%s] save perent context completed", __func__);
        
    }
    NSLog(@"[%s] save completed", __func__);
}

- (void) downloadGeneralItems {
    for (GeneralItemData* giData in [GeneralItemData getUnsyncedData:self.context]) {
        NSLog(@"[%s] gidata url = %@ replicated = %@ error = %@ ", __func__, giData.url, giData.replicated, giData.error);
        NSURL  *url = [NSURL URLWithString:giData.url];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData ){
            giData.data = urlData;
            giData.replicated = [NSNumber numberWithBool:YES];
        } else {
            NSLog(@"[%s] sth went wrong", __func__);
        }
        
        [self saveContext];
    }
}

@end
