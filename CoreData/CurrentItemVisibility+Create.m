//
//  CurrentItemVisibility+Create.m
//  ARLearn
//
//  Created by Stefaan Ternier on 8/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "CurrentItemVisibility+Create.h"

@implementation CurrentItemVisibility (Create)

/*!
 *  Create a CurrentItemVisibility in Core Data.
 *
 *  @param generalItem The GeneralItem to create the CurrentItemVisibility for.
 *  @param run         The Run.
 *
 *  @return The newly created CurrentItemVisibility.
 */
+ (CurrentItemVisibility *) create: (GeneralItem *) generalItem withRun: (Run *) run {

    CurrentItemVisibility *visibility = [NSEntityDescription insertNewObjectForEntityForName:@"CurrentItemVisibility"
                                              inManagedObjectContext:run.managedObjectContext];

    
    //WARNING: Default CurrentItemVisibility.visible was NO. But it's not retrieved anywhere from the server except ini ARLAppearDisappearDelegator which seems unused and contains a hardcoded runId.
    
    visibility.visible = [NSNumber numberWithBool:YES];
    visibility.item = generalItem;
    visibility.run = run;
    
    [INQLog SaveNLog:run.managedObjectContext];
    
    return visibility;
}

/*!
 *  Update a CurrentItemVisibility records of all GenralItems of a Run in Core Data.
 *
 *  @param runId   The RunId.
 *  @param context The NSManagedObjectContext.
 */
+ (void) updateVisibility : (NSNumber *) runId withManagedContext: (NSManagedObjectContext *) context{
    for (GeneralItem *gi in [GeneralItem retrieve:runId withManagedContext:context]) {
        [self updateVisibility:gi.generalItemId runId:runId withManagedContext:context];
    }
}

/*!
 *  Update a CurrentItemVisibility record in Core Data.
 *
 *  @param itemId  The CurrentItemVisibility Id.
 *  @param runId   The RunId.
 *  @param context The NSManagedObjectContext.
 */
+ (void) updateVisibility : (NSNumber *) itemId runId:(NSNumber*) runId withManagedContext: (NSManagedObjectContext *) context{
    NSNumber *timeDelta = [[NSUserDefaults standardUserDefaults] objectForKey:@"timDelta"];
    
    CurrentItemVisibility *visibility = [self retrieve:itemId runId:runId withManagedContext:context];
    
    double localCurrentTimeMillis = [[NSDate date] timeIntervalSince1970]*1000;
    double currentTimeMillis = localCurrentTimeMillis - timeDelta.longLongValue* 1000;
    
    GeneralItemVisibility *appearAt;
    GeneralItemVisibility *disAppearAt;
    for (GeneralItemVisibility* visibilityStatement in [GeneralItemVisibility retrieve:itemId runId:runId withManagedContext:context]) {
        if (visibilityStatement.status.intValue == 1) appearAt = visibilityStatement;
        if (visibilityStatement.status.intValue == 2) disAppearAt = visibilityStatement;
    }
    
    if (appearAt) {
        if (appearAt.timeStamp.doubleValue < currentTimeMillis) {
                visibility.visible = [NSNumber numberWithBool:YES];
        } else {
            DLog(@"***this item is not yet visible. Set a timer %@", appearAt.generalItem.name);

            double longValue =appearAt.timeStamp.longLongValue - currentTimeMillis;
            
            DLog(@"***%f !< %f wait %f milliseconds", appearAt.timeStamp.doubleValue, currentTimeMillis, longValue);
            
            NSDate* triggerTime = [NSDate dateWithTimeIntervalSince1970:(localCurrentTimeMillis + longValue)/1000];
           [[ARLAppearDisappearDelegator sharedSingleton] setTimer:triggerTime];
        }
    }
    
    if (disAppearAt) {
        if (disAppearAt.timeStamp.doubleValue < currentTimeMillis) {
            visibility.visible = [NSNumber numberWithBool:NO];    
        }else {
            DLog(@"***this item is not yet invisible. Set a timer");
            
            double longValue =disAppearAt.timeStamp.longLongValue - currentTimeMillis;
            
            DLog(@"***%f !< %f wait %f milliseconds", disAppearAt.timeStamp.doubleValue, currentTimeMillis, longValue);
            
            NSDate* triggerTime = [NSDate dateWithTimeIntervalSince1970:(localCurrentTimeMillis + longValue)/1000];
            
            [[ARLAppearDisappearDelegator sharedSingleton] setTimer:triggerTime];
        }
    }
}


/*!
 *  Fetch a CurrentItemVisibility from Core Data.
 *
 *  @param itemId  The GeneralItemId.
 *  @param runId   The RunId.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested CurrentItemVisibility.
 */
+ (CurrentItemVisibility *) retrieve: (GeneralItem *) item runId:(NSNumber *) runId withManagedContext: (NSManagedObjectContext *) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CurrentItemVisibility"];

    request.predicate = [NSPredicate predicateWithFormat:@"item = %@ and run.runId = %lld", item, [runId longLongValue]];
    NSError *error = nil;
    
    NSArray *currentItemVisibility = [context executeFetchRequest:request error:&error];
    
    ELog(error);
    
    if (!currentItemVisibility || ([currentItemVisibility count] != 1)) {
        return nil;
    } else {
        return [currentItemVisibility lastObject];
    }
}

/*!
 *  Retrieve CurrentItemVisibility for a Run with Visible set to 1.
 *
 *  @param runId   The RunId.
 *  @param context The NSManagedObjectContext.
 *
 *  @return An Array with CurrentItemVisibility that are visible.
 */
+ (NSArray *) retrieveVisibleFor: (NSNumber *) runId withManagedContext: (NSManagedObjectContext *) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CurrentItemVisibility"];
    request.predicate = [NSPredicate predicateWithFormat:@"visible = 1 and run.runId = %lld", [runId longLongValue]];
    
    NSError *error = nil;
    return [context executeFetchRequest:request error:&error];
}

@end
