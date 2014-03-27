//
//  Action+Create.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/23/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "Action+Create.h"

@implementation Action (Create)

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
    
    NSError *error = nil;
    [context save:&error];
    if (error) {
        NSLog(@"[%s] error %@", __func__, error);
    }
    
    return action;
}

+ (NSArray *) getUnsyncedActions: (NSManagedObjectContext*) context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Action"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"synchronized = %d", NO];
    
    NSError *error = nil;
    NSArray *unsyncedActions = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"[%s] error %@", __func__, error);
    }
    
    return unsyncedActions;
}

+ (BOOL) checkAction:(NSString *) action
      forGeneralItem: (GeneralItem *) gi
              forRun: (Run *) run
inManagedObjectContext:(NSManagedObjectContext*) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Action"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"generalitem.generalItemId = %@ AND run.runId = %@ AND action = %@", gi.generalItemId, run.runId, action];
    
    NSError *error = nil;
    NSUInteger * count = [context countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"[%s] error %@", __func__, error);
    }
    
    return count!=0;
}

@end
