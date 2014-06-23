//
//  SynchronizationBookKeeping+create.m
//  ARLearn
//
//  Created by Stefaan Ternier on 2/4/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "SynchronizationBookKeeping+create.h"

@implementation SynchronizationBookKeeping (create)

/*!
 *  Get the Last Synchronization Date with nil Context Identifier.
 *
 *  @param context The NSManagedObjectContext.
 *  @param type    The type to retrieve the Synchronization Date for.
 *
 *  @return The Last Synchronization Date.
 */
+ (NSNumber *) getLastSynchronizationDate : (NSManagedObjectContext *) context type:(NSString *) type{
    return [self getLastSynchronizationDate:context type:type context:nil];
}

/*!
 *  Get the Last Synchronization Date.
 *
 *  @param context The NSManagedObjectContext.
 *  @param type    The type to retrieve the Synchronization Date for.
 *  @param context The Synchronization Context Identifier.
 *
 *  @return The Last Synchronization Date.
 */
+ (NSNumber*) getLastSynchronizationDate : (NSManagedObjectContext *) managedContext type:(NSString *) type context:(NSNumber *) identifierContext {
    //NSString * key = [NSString stringWithFormat:@"%@+%@", type, identifierContext];
    //SynchronizationBookKeeping * objectFromCache = [[ARLCloudSynchronizer syncDates] objectForKey:key];
    //if (objectFromCache) {
    //  return objectFromCache.lastSynchronization;
    //}
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"SynchronizationBookKeeping"];
    if (identifierContext) {
        fetch.predicate = [NSPredicate predicateWithFormat: @"type = %@ and context = %lld", type, [identifierContext longLongValue]];
    } else {
        fetch.predicate = [NSPredicate predicateWithFormat: @"type = %@ ", type];
    }
    NSError *error;
    NSArray *result = [managedContext executeFetchRequest:fetch error:&error];
    ELog(error);
    
    if ([result count] == 0) {
        return [NSNumber numberWithInt:0];
    } else {
        SynchronizationBookKeeping * bookKeeping = [result lastObject];
        
        //[[ARLCloudSynchronizer syncDates] setObject:bookKeeping forKey:key];
        
        [managedContext save:&error];
        ELog(error);
        
        return bookKeeping.lastSynchronization;
    }
}

/*!
 *  Create a SynchronizationBookKeeping record with a nil Synchronization Context Identifier.
 *
 *  @param type    The Synchronization Type.
 *  @param time    The Synchronization Time/Data
 *  @param context The NSManagedObjectContext.
 *
 *  @return The SynchronizationBookKeeping record.
 */
+ (SynchronizationBookKeeping *) createEntry: (NSString *) type
                                        time: (NSNumber *) time
                      inManagedObjectContext: (NSManagedObjectContext * ) context {

    return [self createEntry:type time:time idContext:nil inManagedObjectContext:context];
}

/*!
 *  Create a SynchronizationBookKeeping record.
 *
 *  @param type    The Synchronization Type.
 *  @param time    The Synchronization Time/Data
 *  @param idContext The Synchronization Context Identifier.
 *  @param context   The NSManagedObjectContext.
 *
 *  @return The SynchronizationBookKeeping record.
 */
+ (SynchronizationBookKeeping *) createEntry: (NSString *) type
                                        time: (NSNumber *) time
                                   idContext: (NSNumber *) idContext
                      inManagedObjectContext: (NSManagedObjectContext *) context {
    
    SynchronizationBookKeeping * bkItem = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SynchronizationBookKeeping"];
    if (idContext) {
        request.predicate = [NSPredicate predicateWithFormat: @"type = %@ and context = %lld", type, [idContext longLongValue]];
    } else {
        request.predicate = [NSPredicate predicateWithFormat: @"type = %@ ", type];
    }
    
    NSArray *bkItems = [context executeFetchRequest:request error:nil];
    if (!bkItems || ([bkItems count] > 1)) {
        // handle error
    } else if (![bkItems count]) {
        bkItem = [NSEntityDescription insertNewObjectForEntityForName:@"SynchronizationBookKeeping"
                                               inManagedObjectContext:context];
        bkItem.type = type;
    } else {
        bkItem = [bkItems lastObject];
    }
    
    if (idContext) {
        bkItem.context = idContext;
    }
    
    bkItem.lastSynchronization = time;
   
    NSError *error = nil;
    [context save:&error];
    ELog(error);
    
    return bkItem;
}

@end
