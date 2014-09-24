//
//  Run+ARLearnBeanCreate.m
//  ARLearn
//
//  Created by Stefaan Ternier on 2/2/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "Run+ARLearnBeanCreate.h"

@implementation Run (ARLearnBeanCreate)

/*!
 *  Retrieve a Run given a RunId.
 *
 *  @param runId   The RunId.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested Run.
 */
+ (Run *) retrieveRun: (NSNumber *) runId inManagedObjectContext: (NSManagedObjectContext *) context {
    Run *run = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Run"];
    request.predicate = [NSPredicate predicateWithFormat:@"runId = %lld", [runId longLongValue]];
    NSError *error = nil;
    NSArray *runs = [context executeFetchRequest:request error:&error];
    
    if (!runs || [runs count] > 0) {
        run = [runs lastObject];
    }
    return run;
}
/*!
 *  Retrieve a Run given a dictionary.
 *
 *  @param runDict Should at least contain runId, title, owner, gameId and runId. May contain deleted.
 *  @param context <#context description#>
 *
 *  @return <#return value description#>
 */
+ (Run *) runWithDictionary: (NSDictionary *) runDict inManagedObjectContext: (NSManagedObjectContext *) context {
    Run *run = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Run"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"runId = %lld", [[runDict objectForKey:@"runId"] longLongValue]];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *runs = [context executeFetchRequest:request error:&error];
    if (!runs || ([runs count] > 1)) {
        // handle error
    } else if (![runs count]) {
        if (![[runDict objectForKey:@"deleted"] boolValue]) {
            run = [NSEntityDescription insertNewObjectForEntityForName:@"Run"
                                                inManagedObjectContext:context];
        }
        
    } else {
        run = [runs lastObject];
        
    }
    if ([[runDict objectForKey:@"deleted"] boolValue]) {
        [run.managedObjectContext deleteObject:run];
        [SynchronizationBookKeeping createEntry:@"generalItemsVisibility"
                                           time:0
                                      idContext:run.runId
                         inManagedObjectContext:context];
    } else {
        run.title = [runDict objectForKey:@"title"];
        run.owner = [runDict objectForKey:@"owner"];
        run.gameId = [runDict objectForKey:@"gameId"] ;
        run.runId = [runDict objectForKey:@"runId"] ;
        run.deleted = [NSNumber numberWithBool:NO];
        
        [self setGame:run inManagedObjectContext:context];
    }
    
    [INQLog SaveNLog:context];
    
    return run;
}

/*!
 *  Set the Games of a Run.
 *
 *  @param run     The Run.
 *  @param context The NSManagedObjectContext.
 */
+ (void) setGame: (Run *) run inManagedObjectContext: (NSManagedObjectContext *) context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"gameId = %lld", [run.gameId longLongValue]];
   
    NSError *error = nil;
    NSArray *games = [context executeFetchRequest:request error:&error];
    if (!games || ([games count] > 1)) {
      // handle error
    } else if (![games count]) {
        
    } else {
        Game *game = [games lastObject];
        run.game = game;
    }
}

@end
