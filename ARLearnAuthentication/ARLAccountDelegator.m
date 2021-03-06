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
 *  Do not call this method directly  but use ARLAppDelegate.LogOut instead.
 *
 *  @param context The NSManagedObjectContext
 */
+ (void) deleteCurrentAccount: (NSManagedObjectContext * ) context {
    // Delete only the current account.
    Account *account = [Account retrieveFromDbWithLocalId:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"]
                                              accountType:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]                                       withManagedContext:context];
    
    if (account!=nil) {
        [context deleteObject:account];
    }

    [INQLog SaveNLog:context];
}

/*!
 *  Reset all data associated to an account. 
 *  Also reset the synchronization bookkeeping.
 *
 *  @param The NSManagedObjectContext
 */
+ (void) resetAccount: (NSManagedObjectContext *) context {
    NSNumber* serverTime = [NSNumber numberWithLong:0];
  
    // Update Synchronization Bookkeeping
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"SynchronizationBookKeeping"];
    
    [SynchronizationBookKeeping createEntry:@"myRuns" time:serverTime inManagedObjectContext:context];
    [SynchronizationBookKeeping createEntry:@"myGames" time:serverTime inManagedObjectContext:context];
    [SynchronizationBookKeeping createEntry:@"generalItems" time:serverTime inManagedObjectContext:context];
    [SynchronizationBookKeeping createEntry:@"generalItemsVisibility" time:serverTime inManagedObjectContext:context];
    
    //Clear all tables.
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Account"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Action"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"CurrentItemVisibility"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Game"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"GeneralItem"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"GeneralItemData"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"GeneralItemVisibility"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Inquiry"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Message"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Response"];
    [ARLAccountDelegator deleteAllOfEntity:context enityName:@"Run"];
    
    [self saveChanges:context];
}

+ (void) saveChanges : (NSManagedObjectContext *) context {
    [INQLog SaveNLogAbort:context func:[NSString stringWithFormat:@"%s",__func__]];
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
        [ARLNetwork ShowAbortMessage:error func:[NSString stringWithFormat:@"%s",__func__]];
    }
    
    for (id entity in entities) {
        [context deleteObject:entity];
    }
    
    [INQLog SaveNLog:context];
}

@end
