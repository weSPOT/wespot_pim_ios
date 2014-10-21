//
//  GeneralItem+ARLearnBeanCreate.m
//  ARLearn
//
//  Created by Stefaan Ternier on 2/3/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "GeneralItem+ARLearnBeanCreate.h"


@implementation GeneralItem (ARLearnBeanCreate)


/*!
 *  Create or Retrieve a GeneralItem given a NSDictionay.
 *
 *  @param giDict  The Dictionary.
 *  @param gameId  The GameId.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested GeneralItem.
 */
+ (GeneralItem *) generalItemWithDictionary: (NSDictionary *) giDict
                                 withGameId: (NSNumber *) gameId
                     inManagedObjectContext: (NSManagedObjectContext *) context {
    
    Game *game = [Game retrieveGame:gameId inManagedObjectContext:context];
    
    return [self generalItemWithDictionary:giDict withGame:game inManagedObjectContext:context];
}

/*!
 *  Create or Retrieve a GeneralItem given a NSDictionay.
 *
 *  @param giDict  Should at least contain id, latm lng, name, richText, sortKey, type. Optional is deleted.
 *  @param gameId  The Game.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested GeneralItem.
 */
+ (GeneralItem *) generalItemWithDictionary: (NSDictionary *) giDict
                                   withGame: (Game *) game
                     inManagedObjectContext: (NSManagedObjectContext *) context {
    
    GeneralItem *gi = [self retrieveFromDb:giDict withManagedContext:context];
    if ([[giDict objectForKey:@"deleted"] boolValue]) {
        if (gi) {
            //item is deleted
            [context deleteObject:gi];
            gi=nil;
        }
        return nil;
    }
    if (!gi) {
        gi = [NSEntityDescription insertNewObjectForEntityForName:@"GeneralItem"
                                           inManagedObjectContext:context];
    }
    
#pragma warn VEG CREATE GI here with a local id of 0 if missing in dictionary.
    
    if ([giDict objectForKey:@"id"]) {
        gi.generalItemId = [giDict objectForKey:@"id"];
    } else {
        gi.generalItemId = 0;
    }
    gi.ownerGame = game;
    gi.gameId = [giDict objectForKey:@"gameId"];
    gi.lat = [giDict objectForKey:@"lat"];
    gi.lng = [giDict objectForKey:@"lng"];
    gi.name = [giDict objectForKey:@"name"];
    gi.richText = [giDict objectForKey:@"richText"];
    gi.sortKey = [giDict objectForKey:@"sortKey"] ;
    gi.type = [giDict objectForKey:@"type"];
    gi.json = [NSKeyedArchiver archivedDataWithRootObject:giDict];
    
    if ( gi.generalItemId != 0) {
        [self setCorrespondingVisibilityItems:gi];
        
        [self downloadCorrespondingData:giDict withGeneralItem:gi inManagedObjectContext:context];
    }
    
    [INQLog SaveNLog:context];
    
    return gi;
}

/*!
 *  Create a download task to download the iconUrl of a GeneralItem.
 *
 *  @param giDict  Should at least contain iconUrl.
 *  @param gi      The GeneralItem to download for.
 *  @param context The NSManagedObjectContext.
 */
+ (void) downloadCorrespondingData: (NSDictionary *) giDict
                   withGeneralItem: (GeneralItem *) gi
            inManagedObjectContext: (NSManagedObjectContext *) context {
    NSDictionary *jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:gi.json];
    
    if ([jsonDict objectForKey:@"iconUrl"]) {
        [GeneralItemData createDownloadTask:gi withKey:@"iconUrl" withUrl:[jsonDict objectForKey:@"iconUrl"] withManagedContext:context];
    } else if ([gi.type caseInsensitiveCompare:@"org.celstec.arlearn2.beans.generalItem.AudioObject"] == NSOrderedSame ){
        [GeneralItemData createDownloadTask:gi withKey:@"audio" withUrl:[jsonDict objectForKey:@"audioFeed"] withManagedContext:context];
    } else if ([gi.type caseInsensitiveCompare:@"org.celstec.arlearn2.beans.generalItem.VideoObject"] == NSOrderedSame ){
        [GeneralItemData createDownloadTask:gi withKey:@"video" withUrl:[jsonDict objectForKey:@"videoFeed"] withManagedContext:context];
    }
}

/*!
 *  Set the GeneralItem of the Set of GeneralItemVisibility.
 *
 *  @param gi The GeneralItem.
 */
+ (void) setCorrespondingVisibilityItems: (GeneralItem *) gi {
    NSManagedObjectContext * context = gi.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GeneralItemVisibility"];
    request.predicate = [NSPredicate predicateWithFormat:@"generalItem == %@", gi];
    
    NSError *error = nil;
    NSArray *allVisibilityStatements = [context executeFetchRequest:request error:&error];
    ELog(error);
    
    for (GeneralItemVisibility *giv in allVisibilityStatements) {
        giv.generalItem = gi;
    }
    
    [INQLog SaveNLog:context];
}

/*!
 *  Retrieve a GneralItem given its Id.
 *
 *  @param itemId  The GeneralItemId
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested GeneralItem.
 */
+ (GeneralItem *) retrieveFromDbWithId: (NSNumber *) itemId withManagedContext: (NSManagedObjectContext *) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GeneralItem"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"generalItemId = %lld", [itemId longLongValue]];
    
    NSError *error = nil;
    NSArray *generalItemsFromDb = [context executeFetchRequest:request error:&error];
    ELog(error);
    
    if (!generalItemsFromDb || ([generalItemsFromDb count] != 1)) {
        return nil;
    } else {
        return [generalItemsFromDb lastObject];
    }
}

/*!
 *  Retrieve a GneralItem given a Dictionary.
 *
 *  @param giDict  Should at least contain id.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested GeneralItem.
 */
+ (GeneralItem *) retrieveFromDb: (NSDictionary *) giDict withManagedContext: (NSManagedObjectContext *) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GeneralItem"];
    
    if ([giDict objectForKey:@"id"]) {
        request.predicate = [NSPredicate predicateWithFormat:@"generalItemId = %lld", [[giDict objectForKey:@"id"] longLongValue]];
    } else {
        
        //TODO: Retrieve Correct Item Here...
    }
    NSError *error = nil;
    NSArray *generalItemsFromDb = [context executeFetchRequest:request error:&error];
    ELog(error);
    
    if (!generalItemsFromDb || ([generalItemsFromDb count] != 1)) {
        return nil;
    } else {
        return [generalItemsFromDb lastObject];
    }
}

/*!
 *  Get All GeneralItems.
 *
 *  @param context The NSManagedObjectContext.
 *
 *  @return An Array with all GeneralItems.
 */
+ (NSArray *) getAll: (NSManagedObjectContext *) context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GeneralItem"];

    NSError *error = nil;
    NSArray *unsyncedData = [context executeFetchRequest:request error:&error];
    ELog(error);
    
    return unsyncedData;
}

/*!
 *  Retrieve all GeneralItems of a Run.
 *
 *  @param runId   The RunId.
 *  @param context The NSManagedObjectContext.
 *
 *  @return An Array containing all GeneralItems of a Run.
 */
+ (NSArray *) retrieve: (NSNumber *) runId withManagedContext: (NSManagedObjectContext *) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GeneralItem"];
    
    NSNumber *gameId = [Run retrieveRun:runId inManagedObjectContext:context].gameId;
    
    request.predicate = [NSPredicate predicateWithFormat:@"gameId =%lld ",
                         [gameId longLongValue]
                         ];
    
    return [context executeFetchRequest:request error:nil];
}

/*!
 *  Search for GeneralItemData of this GeneralItem containing iconUrl in its data.
 *
 *  @return An array of iconUrl Urls.
 */
- (NSData *) customIconData {
    for (GeneralItemData *data in self.data) {
        
        DLog(@"Data %@", data.name);
        
        if ([data.name isEqualToString:@"iconUrl"]) {
            return data.data;
        }
    }
    
    return nil;
}

@end
