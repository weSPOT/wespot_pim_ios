//
//  GeneralItemVisibility+ARLearnBeanCreate.m
//  ARLearn
//
//  Created by Stefaan Ternier on 2/3/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "GeneralItemVisibility+ARLearnBeanCreate.h"


@implementation GeneralItemVisibility (ARLearnBeanCreate)

/*!
 *  Retrieve GeneralItemVisibility record given a Dictionary, Run and GeneralItem?.
 *
 *  @param visDict     Should at least contain title, generalItemId, runId, status, timeStamp and email. May contain deleted.
 *  @param run         The RunId.
 *  @param generalItem The GeneralItem.
 *
 *  @return The requsted GeneralItemVisibility.
 */
+ (GeneralItemVisibility *) visibilityWithDictionary: (NSDictionary *) visDict withRun: (Run *) run withGeneralItem: (GeneralItem *) generalItem {
    GeneralItemVisibility * giVis = [self retrieveFromDb:visDict withManagedContext:run.managedObjectContext];
    
#warning since generalItem parameter is unused this method is identical to the one below. Seems a private method.
    
    BOOL newItemCreated = false;
    if ([[visDict objectForKey:@"deleted"] boolValue]) {
        //item is deleted
        [giVis.managedObjectContext deleteObject:giVis];
        giVis = nil;
        return nil;
    }
    if (!giVis) {
        giVis = [NSEntityDescription insertNewObjectForEntityForName:@"GeneralItemVisibility"
                                              inManagedObjectContext:run.managedObjectContext];
        newItemCreated = true;
    }
    giVis.correspondingRun = run;
    //    giVis.generalItem = generalItem;
    giVis.timeStamp = [visDict objectForKey:@"title"] ;
    giVis.generalItemId = [visDict objectForKey:@"generalItemId"] ;
    giVis.runId = [visDict objectForKey:@"runId"] ;
    giVis.status = [visDict objectForKey:@"status"] ;
    giVis.timeStamp =[visDict objectForKey:@"timeStamp"] ;
    
    // veg 26-06-2014 disabled because notification api is disabled.
    //    if ([giVis.timeStamp doubleValue] < ([[NSDate date] timeIntervalSince1970]*1000)) {
    //        if ([giVis.timeStamp doubleValue] > ([[NSDate date] timeIntervalSince1970]*1000 - 5000)) {
    //            if (newItemCreated && [(NSNumber*)giVis.status intValue]== 1) {
    //                [[ARLNotificationPlayer sharedSingleton] playNotification];
    //            }
    //        }
    //        
    //    }
    
    giVis.email =[visDict objectForKey:@"email"];
    
    NSError *error = nil;
    [run.managedObjectContext save:&error];
    
    return giVis;
}

/*!
 *  Retrieve GeneralItemVisibility record given a Dictionary, Run.
 *
 *  @param visDict     Should at least contain title, generalItemId, runId, status, timeStamp and email. May contain deleted.
 *  @param run         The RunId.
 *  @param generalItem The GeneralItem.
 *
 *  @return The requsted GeneralItemVisibility.
 */
+ (GeneralItemVisibility *) visibilityWithDictionary: (NSDictionary *) visDict withRun: (Run *) run {
    GeneralItem *generalItem = [GeneralItem retrieveFromDbWithId:[visDict objectForKey:@"generalItemId"] withManagedContext:run.managedObjectContext];
    
    CurrentItemVisibility *currentVisibility = [CurrentItemVisibility retrieve:[visDict objectForKey:@"generalItemId"] runId:run.runId withManagedContext:run.managedObjectContext];
    
    if (generalItem) {
        if (!currentVisibility) {
            [CurrentItemVisibility create:generalItem withRun:run];
        }
        GeneralItemVisibility * vis = [self visibilityWithDictionary:visDict
                                                             withRun:run
                                                     withGeneralItem:generalItem];
        
        [generalItem addVisibilityObject:vis];
        [CurrentItemVisibility updateVisibility:generalItem.generalItemId runId:run.runId withManagedContext:run.managedObjectContext];
        
        NSError *error = nil;
        [run.managedObjectContext save:&error];
        
        return vis;
    }
    return nil;
    
}

/*!
 *  Retrieve a GeneralItemVisibility from Core Data given a dictionary.
 *
 *  @param visDict Should at least contain generalItemId, email, runId and status.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested record.
 */
+ (GeneralItemVisibility *) retrieveFromDb: (NSDictionary *) visDict withManagedContext: (NSManagedObjectContext *) context{
    GeneralItemVisibility *giVis = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GeneralItemVisibility"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"generalItemId = %lld and email = %@ and runId =%lld and status = %ld",
                         [[visDict objectForKey:@"generalItemId"] longLongValue],
                         [visDict objectForKey:@"email"] ,
                         [[visDict objectForKey:@"runId"] longLongValue],
                         [[visDict objectForKey:@"status"] intValue]
                         ];
    NSError *error = nil;
    NSArray *giVises = [context executeFetchRequest:request error:&error];
    ELog(error);
    
    if (!giVises || ([giVises count] != 1)) {
        return nil;
    } else {
        giVis = [giVises lastObject];
        return giVis;
    }
}

/*!
 *  Retrieve all GeneralItemVisibility's given a GeneralItem and a Run.
 *
 *  @param itemId  The GeneralItemId
 *  @param runId   The RunId.
 *  @param context The NSManagedObjectContext.
 *
 *  @return An array of GeneralItemVisibility records.
 */
+ (NSArray *) retrieve: (NSNumber *) itemId runId:(NSNumber *) runId withManagedContext: (NSManagedObjectContext *) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GeneralItemVisibility"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"generalItemId = %lld and runId =%lld ",
                         [itemId longLongValue],
                         [runId longLongValue]
                         ];
    
    return [context executeFetchRequest:request error:nil];
}

/*!
 *  Retrieve all GeneralItemVisibility's given a Run.
 *
 *  @param itemId  The GeneralItemId
 *  @param runId   The RunId.
 *  @param context The NSManagedObjectContext.
 *
 *  @return An array of GeneralItemVisibility records.
 */
+ (NSArray *) retrieve :(NSNumber *) runId withManagedContext: (NSManagedObjectContext *) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GeneralItemVisibility"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"runId =%lld ",
                         [runId longLongValue]
                         ];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"generalItemId" ascending:YES];
    
    [request setSortDescriptors:@[sortDescriptor]];
    
    return [context executeFetchRequest:request error:nil];
}

@end
