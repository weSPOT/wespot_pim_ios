//
//  ARLAccountDelegator.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLAccountDelegator.h"
#import "SynchronizationBookKeeping+create.h"
#import "Run+ARLearnBeanCreate.h"
#import "GeneralItemVisibility+ARLearnBeanCreate.h"
#import "Response+Create.h"

@implementation ARLAccountDelegator


/*!
 *  Remove all accounts and associated data.
 *
 *  @param context The NSManagedObjectContext
 */
+ (void) deleteCurrentAccount: (NSManagedObjectContext * ) context {
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Run"];

    [self resetAccount:context];
}

/*!
 *  Reset all data associated to an account. 
 *  Also reset thesynchronization bookkeeping.
 *
 *  @param The NSManagedObjectContext
 */
+ (void) resetAccount: (NSManagedObjectContext *) context {
    NSNumber* serverTime = [NSNumber numberWithLong:0];
    
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"SynchronizationBookKeeping"];
    
    [SynchronizationBookKeeping createEntry:@"myRuns" time:serverTime inManagedObjectContext:context];
    [SynchronizationBookKeeping createEntry:@"myGames" time:serverTime inManagedObjectContext:context];
    [SynchronizationBookKeeping createEntry:@"generalItems" time:serverTime inManagedObjectContext:context];
    [SynchronizationBookKeeping createEntry:@"generalItemsVisibility" time:serverTime inManagedObjectContext:context];
    
    //[GeneralItemVisibility deleteAll:context];
    //[Response deleteAll:context];
    
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Run"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Game"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"GeneralItemVisibility"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"GeneralItem"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Inquiry"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Response"];
    
    [self saveChanges:context];
}

+ (void) saveChanges : (NSManagedObjectContext *) context {
    NSError *error = nil;
    if (context) {
        if ([context hasChanges]){
            if (![context save:&error]) {
                NSLog(@"[%s] Unresolved error %@, %@", __func__, error, [error userInfo]);
                abort();
            }
        }
    }
}

/*!
 *  Delete all records of the specified entity type.
 *
 *  @param context The NSManagedObjectContext
 *  @param name    The entity name.
 */
+ (void) deleteAllOfEntity: (NSManagedObjectContext *) context enityName:(NSString *)name {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
    
    NSError *error = nil;
    NSArray *entities = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"error %@", error);
        abort();
    }
    for (id entity in entities) {
        [context deleteObject:entity];
    }
    
    [context save:&error];
}

@end
