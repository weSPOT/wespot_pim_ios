//
//  ARLCloudSynchronizer.m
//  ARLearn
//
//  Created by Stefaan Ternier on 2/4/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLCloudSynchronizer.h"

@implementation ARLCloudSynchronizer

@synthesize syncRuns = _syncRuns;
@synthesize syncGames = _syncGames;

@synthesize syncResponses = _syncResponses;
@synthesize syncActions = _syncActions;

@synthesize gameId = _gameId;
@synthesize visibilityRunId = _visibilityRunId;

@synthesize context = _context;

+ (void) syncGamesAndRuns:(NSManagedObjectContext*)context
{
    ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncGames = YES;
    synchronizer.syncRuns = YES;
    
    [synchronizer sync];
}

+ (void) syncResponses:(NSManagedObjectContext*)context
{
    ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncResponses = YES;
    synchronizer.syncActions = YES;
    
    [synchronizer sync];
}

+ (void) syncActions:(NSManagedObjectContext*)context
{
    // DLog(@"");
    
    ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncActions = YES;
    
    [synchronizer sync];
}

/*!
 *  Synchronizes Visibility for a Run
 *
 *  @param context The Core Data Context
 *  @param run The Run to sync for
 */
+ (void) syncVisibilityForInquiry:(NSManagedObjectContext*)context
                              run:(Run *)run
{
    // DLog(@"");
    
    ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.gameId = run.gameId;
    synchronizer.visibilityRunId = run.runId;
    
    [synchronizer sync];
}

/*!
 *  Call asyncExecution on a background thread.
 */
- (void) sync {
    [self.context performBlock:^{
        [self asyncExecution];
    }];
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
    // CLog(@"Saving NSManagedObjectContext");
    
    //RawLog(@"");
    
    [INQLog SaveNLogAbort:self.context func:[NSString stringWithFormat:@"%s",__func__]];
    [self.parentContext performBlock:^{
        [INQLog SaveNLogAbort:self.parentContext func:[NSString stringWithFormat:@"%s",__func__]];
    }];
}

- (void) createContext: (NSManagedObjectContext*) mainContext {
    self.parentContext = mainContext;
    
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.context.parentContext = mainContext;
}

- (void) asyncExecution {
    // mach_port_t machTID = pthread_mach_thread_np(pthread_self());
    // DLog(@"Thread:0x%x - %@ - %@", machTID, @"Checking Lock", ARLAppDelegate.theLock);
    
    [ARLAppDelegate.theLock lock];
 
    // DLog(@"Thread:0x%x - %@ - %@", machTID, @"Passed Lock", ARLAppDelegate.theLock);
  
    // DLog(@"Thread:0x%x - Start of ARL Synchronisation", machTID);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    while (ARLAppDelegate.SyncAllowed) {
        if (self.syncRuns) {
            // Log(@"synchronizeRuns");
            [self synchronizeRuns];
        } else if (self.syncGames) {
            // Log(@"synchronizeGames");
            [self synchronizeGames];
        } else if (self.gameId) {
            // Log(@"synchronizeGeneralItemsWithGame");
            [self synchronizeGeneralItemsWithGame];
        } else if (self.visibilityRunId) {
            // Log(@"synchronizeGeneralItemsAndVisibilityStatements");
            [self synchronizeGeneralItemsAndVisibilityStatements];
        } else if (self.syncResponses){
            // Log(@"synchronizeResponses");
            [self synchronizeResponses];
        } else if (self.syncActions){
            // Log(@"synchronizeActions");
            [self synchronizeActions];
        } else {
            break;
        }
    }
    // Log(@"Ready");
    
    if (ARLAppDelegate.SyncAllowed) {
        [self saveContext];
        [NSThread sleepForTimeInterval:0.1];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [ARLAppDelegate.theLock unlock];
   
    // DLog(@"Thread:0x%x - %@ - %@", machTID, @"Exit Lock", ARLAppDelegate.theLock);

    // DLog(@"Thread:0x%x - End of ARL Synchronisation", machTID);
}

- (void) synchronizeRuns { //: (NSManagedObjectContext *) context
    // CLog(@"");
    
    @autoreleasepool {
        NSNumber *lastDate = [SynchronizationBookKeeping getLastSynchronizationDate:self.context type:@"myRuns"];
        NSDictionary *dict = [ARLNetwork runsParticipateFrom:lastDate];
        NSNumber *serverTime = [dict objectForKey:@"serverTime"];
        for (NSDictionary *run in [dict objectForKey:@"runs"]) {
            [Run runWithDictionary:run inManagedObjectContext:self.context];
        }
        if (serverTime && [serverTime intValue] != 0) {
            [SynchronizationBookKeeping createEntry:@"myRuns" time:serverTime inManagedObjectContext:self.context];
        }
    }
    
    self.syncRuns = NO;
}

- (void) synchronizeGames { //: (NSManagedObjectContext *) context{
    // CLog(@"");
    
    @autoreleasepool {
        NSNumber *lastDate = [SynchronizationBookKeeping getLastSynchronizationDate:self.context type:@"myGames"];
        NSDictionary *gdict = [ARLNetwork gamesParticipateFrom:lastDate];
        NSNumber * serverTime = [gdict objectForKey:@"serverTime"];
        
        for (NSDictionary *game in [gdict objectForKey:@"games"]) {
            [Game gameWithDictionary:game inManagedObjectContext:self.context];
        }
        
        if (serverTime && [serverTime intValue] != 0) {
            [SynchronizationBookKeeping createEntry:@"myGames" time:serverTime inManagedObjectContext:self.context];
        }
    }
    self.syncGames = NO;
}

- (void) synchronizeGeneralItemsWithGame {
    // CLog(@"GameId: %@", self.gameId);
    
    @autoreleasepool {
        NSNumber *lastDate = [SynchronizationBookKeeping getLastSynchronizationDate:self.context
                                                                               type:@"generalItems"
                                                                            context:self.gameId];
        
        // Select and Push all GeneralItems for this game with genralItemId =0 and update the id on return!
        
        //WARNING: Fails on == 0
        
        //NSPredicate *localgis = [NSPredicate predicateWithFormat:@"(generalItemId = %@) AND (gameId = %lld)", [NSNumber numberWithInt:0], [self.gameId longLongValue]];
        
        NSPredicate *localgis = [NSPredicate predicateWithFormat:@"(gameId = %lld)", [self.gameId longLongValue]];
        
        // Log(@"%@", localgis);
        
        NSArray *gis = [ARLAppDelegate retrievAllOfEntity:self.context enityName:@"GeneralItem" predicate:localgis];
        
        for (GeneralItem *gi in gis) {
            if (gi.generalItemId!=0) {
                continue;
            }
            NSDictionary *jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:gi.json];
            NSDictionary *openQuestion = [jsonDict objectForKey:@"openQuestion"];
            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"org.celstec.arlearn2.beans.generalItem.NarratorItem",   @"type",
                                  self.gameId,                                              @"gameId",
                                  gi.name,                                                  @"name",
                                  gi.richText,                                              @"description",
                                  gi.richText,                                              @"richText",
                                  openQuestion,                                             @"openQuestion",
                                  nil];
            
            NSDictionary *result = [ARLNetwork postGeneralItemWithDict:dict];
            
            gi.generalItemId = [NSNumber numberWithLongLong:[[result objectForKey:@"id"] longLongValue]];
        }
        
        [INQLog SaveNLog:self.context];
        
        NSDictionary *gisDict = [ARLNetwork itemsForGameFrom:self.gameId
                                                         from:lastDate];
        NSNumber *serverTime = [gisDict objectForKey:@"serverTime"];
        
        Game *game = [Game retrieveGame:self.gameId inManagedObjectContext:self.context];
        
        for (NSDictionary *generalItemDict in [gisDict objectForKey:@"generalItems"]) {
            [GeneralItem generalItemWithDictionary:generalItemDict
                                          withGame:game
                            inManagedObjectContext:self.context];
        }
        
        if (serverTime && [serverTime intValue] != 0) {
            [SynchronizationBookKeeping createEntry:@"generalItems"
                                               time:serverTime
                                          idContext:self.gameId
                             inManagedObjectContext:self.context];
        }
    }
    
    self.gameId = nil;
}

- (void) synchronizeGeneralItemsAndVisibilityStatements {
    // CLog(@"");
    
    @autoreleasepool {
        Run *run = [Run retrieveRun:self.visibilityRunId inManagedObjectContext:self.context];
        [self synchronizeGeneralItemsAndVisibilityStatements:run];
    }
    
    self.visibilityRunId = nil;
}

- (void) synchronizeGeneralItemsAndVisibilityStatements:(Run *)run {
    // CLog(@"Run:%@", run.runId);
    
    @autoreleasepool {
        NSNumber *lastDate = [SynchronizationBookKeeping getLastSynchronizationDate:self.context type:@"generalItemsVisibility" context:run.runId];
        
        NSDictionary *visDict =[ARLNetwork itemVisibilityForRun:run.runId from:lastDate];
        
        //    {
        //        deleted = 0;
        //        responses =     (
        //                         {
        //                             deleted = 0;
        //                             generalItemId = 4596856252268544;
        //                             responseId = 4524418407596032;
        //                             responseValue = "{\"text\":\"\"}";
        //                             runId = 5117857260109824;
        //                             timestamp = 1395396382116;
        //                             type = "org.celstec.arlearn2.beans.run.Response";
        //                             userEmail = "2:101754523769925754305";
        //                         },
        //
        //     }
        
        NSNumber *serverTime = [visDict objectForKey:@"serverTime"];
        NSNumber *currentTimeMillis = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000 )];
        NSNumber *delta = [NSNumber numberWithLongLong:(currentTimeMillis.longLongValue - serverTime.longLongValue)];
        
        [[NSUserDefaults standardUserDefaults] setObject:delta forKey:@"timeDelta"];
        
        if ([[visDict objectForKey:@"generalItemsVisibility"] count] > 0) {
            for (NSDictionary *viStatement in [visDict objectForKey:@"generalItemsVisibility"] ) {
                [GeneralItemVisibility visibilityWithDictionaryAndId:viStatement withRun:run];
                
                [INQLog SaveNLog:self.context];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:INQ_SYNCPROGRESS
                                                                    object:NSStringFromClass([GeneralItemVisibility class])];
            }
        }
        
        if (serverTime && [serverTime intValue] != 0) {
            [SynchronizationBookKeeping createEntry:@"generalItemsVisibility"
                                               time:serverTime
                                          idContext:run.runId
                             inManagedObjectContext:self.context];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:INQ_SYNCREADY
                                                            object:NSStringFromClass([GeneralItemVisibility class])];
    }
    
    {
        NSNumber *lastDate = [SynchronizationBookKeeping getLastSynchronizationDate:self.context type:@"response" context:run.runId];
        
        NSString *token = @"";
        NSNumber *serverTime = @0;
        
        do {
            @autoreleasepool {
                NSDictionary *respDict = (token && token.length!=0) ?
                [ARLNetwork responsesForRun:run.runId from:lastDate token:token]:
                [ARLNetwork responsesForRun:run.runId from:lastDate];
                
                if ([respDict objectForKey:@"serverTime"]) {
                    serverTime = (NSNumber *)[respDict objectForKey:@"serverTime"];
                }
                token = [respDict valueForKey:@"resumptionToken"];
                
                NSArray *responses = (NSArray *)[respDict objectForKey:@"responses"];
                
                respDict = nil;
                
                // Log(@"%d Responses", [responses count]);
                
                for (NSDictionary *response in responses ) {
                    [Response responseWithDictionary:response inManagedObjectContext:self.context];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:INQ_SYNCPROGRESS
                                                                        object:NSStringFromClass([Response class])];
                }
                
                // Done in responseWithDictionary [INQLog SaveNLog:self.context];
            }
        } while (token && token.length>0);
        
        if (serverTime && [serverTime intValue] != 0) {
            [SynchronizationBookKeeping createEntry:@"response"
                                               time:serverTime
                                          idContext:run.runId
                             inManagedObjectContext:self.context];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:INQ_SYNCREADY
                                                            object:NSStringFromClass([Response class])];
    }
    
    self.visibilityRunId = nil;
}

- (void) synchronizeActions {
    // CLog(@"");
    
    @autoreleasepool {
        NSArray* actions =  [Action getUnsyncedActions:self.context];
        for (Action* action in actions) {
            if (ARLAppDelegate.SyncAllowed) {
                [ARLNetwork publishAction:action.run.runId
                                   action:action.action
                                   itemId:action.generalItem.generalItemId
                                     time:action.time
                                 itemType:action.generalItem.type];
                action.synchronized = [NSNumber numberWithBool:YES];
            }
        }
    }
    
    self.syncActions = NO;
}

- (void) synchronizeResponses {
    // CLog(@"");
    
    //  BOOL uploads = NO;
    
    @autoreleasepool {
        NSArray* responses = [Response getUnsyncedReponses:self.context];
        for (Response* resp in responses) {
            if (ARLAppDelegate.SyncAllowed) {
                @autoreleasepool {
                    if (resp.value) {
                        [ARLNetwork publishResponse:resp.run.runId
                                      responseValue:resp.value
                                             itemId:resp.generalItem.generalItemId
                                          timeStamp:resp.timeStamp];
                        
                        resp.synchronized = [NSNumber numberWithBool:YES];
                    } else {
                        // VEG NOT neccesay anymore as the filename already has a random number prepended.
                        u_int32_t random = arc4random();
                        NSString* imageName = [NSString stringWithFormat:@"%u.%@", random, resp.fileName];
                        
                        if (resp.run.runId) {
                            NSString* uploadUrl = [ARLNetwork requestUploadUrl:imageName withRun:resp.run.runId];
                           
                            [ARLNetwork perfomUpload:uploadUrl
                                        withFileName:imageName
                                         contentType:resp.contentType
                                            withData:resp.data];
                            
                            NSString *serverUrl = [NSString stringWithFormat:@"%@/uploadService/%@/%@:%@/%@",
                                                   serviceUrl,
                                                   resp.run.runId,
                                                   [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"],
                                                   [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"],imageName];
                            
                            resp.fileName = serverUrl;
                            
                            // Log(@"Uploaded: %@", serverUrl);
                            
                            NSDictionary *myDictionary;
                            
                            NSString * contentType;
                            if ([resp.contentType isEqualToString:@"audio/aac"]) contentType = @"audioUrl";
                            if ([resp.contentType isEqualToString:@"audio/mp3"]) contentType = @"audioUrl";
                            if ([resp.contentType isEqualToString:@"audio/amr"]) contentType = @"audioUrl";
                            if ([resp.contentType isEqualToString:@"application/jpg"]) contentType = @"imageUrl";
                            if ([resp.contentType isEqualToString:@"video/quicktime"]) contentType = @"videoUrl";
                            
                            if ([resp.width intValue] ==0 ) {
                                myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                serverUrl, contentType, nil];
                                
                            } else {
                                myDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                resp.width, @"width",
                                                resp.height, @"height",
                                                serverUrl, contentType, nil];
                            }
                            
                            NSString* jsonString = [ARLAppDelegate jsonString:myDictionary];
                            
                            [ARLNetwork publishResponse:resp.run.runId
                                          responseValue:jsonString
                                                 itemId:resp.generalItem.generalItemId
                                              timeStamp:resp.timeStamp];
                            
                            resp.synchronized = [NSNumber numberWithBool:YES];
                        }
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:INQ_SYNCPROGRESS
                                                                        object:NSStringFromClass([Response class])];
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:INQ_SYNCREADY
                                                            object:NSStringFromClass([Response class])];
    }
    
    self.syncResponses = NO;
}

@end
