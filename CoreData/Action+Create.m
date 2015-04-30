//
//  Action+Create.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/23/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "Action+Create.h"

@implementation Action (Create)

/*!
 *  Create an action record in Core Data.
 *
 *  @param actionString The Action Name
 *  @param run          The Run
 *  @param gi           The GeneralItem
 *  @param context      the NSManagedObjectContext
 *
 *  @return The newly created action.
 */
+ (Action *) initAction: (NSString *) actionString
                forRun :(Run *) run
         forGeneralItem:(GeneralItem *) gi
 inManagedObjectContext: (NSManagedObjectContext * ) context {
    Action * action = [NSEntityDescription insertNewObjectForEntityForName:@"Action" inManagedObjectContext: context];
    
    action.run = run;
    action.action = actionString;
    action.generalItem = gi;
    action.time = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    action.synchronized = [NSNumber numberWithBool:NO];
    
    [INQLog SaveNLog:context];
    
    return action;
}

/*!
 *  Fetch Actions for which the synchronized is NO.
 *
 *  @param context The NSManagedObjectContext.
 *
 *  @return An array of Actions
 */
+ (NSArray *) getUnsyncedActions: (NSManagedObjectContext*) context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Action"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"synchronized=NULL OR synchronized=%d", NO];
    
    NSError *error = nil;
    NSArray *unsyncedActions = [context executeFetchRequest:request error:&error];

    ELog(error);
    
    return unsyncedActions;
}

/*!
 *  Check if an Action is present.
 *
 *  @param action  The Action Name
 *  @param gi      The GeneralItem
 *  @param run     The Run
 *  @param context The NSManagedObjectContext
 *
 *  @return YES if the action if present else NO.
 */
+ (BOOL) checkAction:(NSString *) action
              forRun: (Run *) run
      forGeneralItem: (GeneralItem *) gi
inManagedObjectContext:(NSManagedObjectContext*) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Action"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"generalItem = %@ AND run = %@ AND action = %@", gi, run, action];
    
    NSError *error = nil;
    NSUInteger * count = [context countForFetchRequest:request error:&error];

    ELog(error);
    
    return count && count!=0;
}

@end
