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

//static NSMutableDictionary *syncDates;

//+ (NSMutableDictionary *) syncDates {
//    if (syncDates == nil) {
//        syncDates = [[NSMutableDictionary alloc] init];
//    }
//    return syncDates;
//}

+ (void) syncGamesAndRuns:(NSManagedObjectContext*)context
{
    NSLog(@"[%s]", __func__);
    
    ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncGames = YES;
    synchronizer.syncRuns = YES;
    
    [synchronizer sync];
}

+ (void) syncResponses:(NSManagedObjectContext*)context
{
    NSLog(@"[%s]", __func__);

    ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncResponses = YES;
    synchronizer.syncActions = YES;
    
    [synchronizer sync];
}

+ (void) syncActions:(NSManagedObjectContext*)context
{
    NSLog(@"[%s]", __func__);
    
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
    NSLog(@"[%s]", __func__);
    
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
    NSError *error = nil;
    
    NSLog(@"[%s] Saving NSManagedObjectContext", __func__);
    
    if (self.context) {
        if ([self.context hasChanges]){
            if (![self.context save:&error]) {
                abort();
            }
        }
        
        if ([self.parentContext hasChanges]) {
            [self.parentContext performBlock:^{
//              NSLog(@"[%s] Saving Parent NSManagedObjectContext", __func__);
                NSError *error = nil;
                if (![self.parentContext save:&error]) {
                    abort();
                }
                
#warning is this the correct spot to sync/responses files?
                
                if (ARLNetwork.networkAvailable) {
                    [ARLFileCloudSynchronizer syncGeneralItems:self.parentContext];
                    
//                  [ARLFileCloudSynchronizer syncResponseData:self.parentContext];
                }
            }];
        }
    }
}

- (void) createContext: (NSManagedObjectContext*) mainContext {
    self.parentContext = mainContext;
    
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.context.parentContext = mainContext;
}

- (void) asyncExecution {
    mach_port_t machTID = pthread_mach_thread_np(pthread_self());
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Checking Lock", ARLAppDelegate.theLock);
    
    [ARLAppDelegate.theLock lock];
 
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Passed Lock", ARLAppDelegate.theLock);
    
    NSLog(@"\r\n[%s 0x%x]\r\n*******************************************\r\nStart of ARL Synchronisation", __func__, machTID);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    while (YES) {
        if (self.syncRuns) {
            [self syncronizeRuns];
        } else if (self.syncGames) {
            [self syncronizeGames];
        } else if (self.gameId) {
            [self synchronizeGeneralItemsWithGame];
        } else if (self.visibilityRunId) {
            [self synchronizeGeneralItemsAndVisibilityStatements];
        } else if (self.syncResponses){
            [self synchronizeResponses];
        } else if (self.syncActions){
            [self synchronizeActions];
        } else {
            [self saveContext];
            [NSThread sleepForTimeInterval:0.25];
            break;
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [ARLAppDelegate.theLock unlock];
    
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Exit Lock", ARLAppDelegate.theLock);
    
    NSLog(@"\r\n[%s 0x%x] End of ARL Synchronisation\r\n*******************************************", __func__, machTID);
}

- (void) syncronizeRuns{ //: (NSManagedObjectContext *) context
    NSLog(@"[%s]", __func__);
    
    @autoreleasepool {
        NSNumber *lastDate = [SynchronizationBookKeeping getLastSynchronizationDate:self.context type:@"myRuns"];
        NSDictionary *dict = [ARLNetwork runsParticipateFrom:lastDate];
        NSNumber *serverTime = [dict objectForKey:@"serverTime"];
        for (NSDictionary *run in [dict objectForKey:@"runs"]) {
            [Run runWithDictionary:run inManagedObjectContext:self.context];
        }
        if (serverTime) {
            [SynchronizationBookKeeping createEntry:@"myRuns" time:serverTime inManagedObjectContext:self.context];
        }
    }
    
    self.syncRuns = NO;
}

- (void) syncronizeGames { //: (NSManagedObjectContext *) context{
    NSLog(@"[%s]", __func__);
    
    @autoreleasepool {
        NSNumber *lastDate = [SynchronizationBookKeeping getLastSynchronizationDate:self.context type:@"myGames"];
        NSDictionary *gdict = [ARLNetwork gamesParticipateFrom:lastDate];
        NSNumber * serverTime = [gdict objectForKey:@"serverTime"];
        
        for (NSDictionary *game in [gdict objectForKey:@"games"]) {
            [Game gameWithDictionary:game inManagedObjectContext:self.context];
        }
        
        if (serverTime) {
            [SynchronizationBookKeeping createEntry:@"myGames" time:serverTime inManagedObjectContext:self.context];
        }
    }
    self.syncGames = NO;
}

- (void) synchronizeGeneralItemsWithGame {
    NSLog(@"[%s]", __func__);
    
    @autoreleasepool {
        NSNumber * lastDate = [SynchronizationBookKeeping getLastSynchronizationDate:self.context type:@"generalItems" context:self.gameId];
 
        NSDictionary * gisDict = [ARLNetwork itemsForGameFrom:self.gameId from:lastDate];
        NSNumber * serverTime = [gisDict objectForKey:@"serverTime"];
        Game * game = [Game retrieveGame:self.gameId inManagedObjectContext:self.context];
        
        for (NSDictionary *generalItemDict in [gisDict objectForKey:@"generalItems"]) {
            [GeneralItem generalItemWithDictionary:generalItemDict
                                          withGame:game
                            inManagedObjectContext:self.context];
            
            
        }
        if (serverTime) {
            [SynchronizationBookKeeping createEntry:@"generalItems"
                                               time:serverTime
                                          idContext:self.gameId
                             inManagedObjectContext:self.context];
        }
    }
    self.gameId = nil;
}

- (void) synchronizeGeneralItemsAndVisibilityStatements {
    NSLog(@"[%s]", __func__);
    
    @autoreleasepool {
        Run * run = [Run retrieveRun:self.visibilityRunId inManagedObjectContext:self.context];
        [self synchronizeGeneralItemsAndVisibilityStatements:run];
    }
    
    self.visibilityRunId = nil;
}

- (void) synchronizeGeneralItemsAndVisibilityStatements: (Run *) run {
    NSLog(@"[%s] run:%@", __func__, run.runId);
    
    @autoreleasepool {
        NSNumber *lastDate = [SynchronizationBookKeeping getLastSynchronizationDate:self.context type:@"generalItemsVisibility" context:run.runId];
        
        NSDictionary *visDict =[ARLNetwork itemVisibilityForRun:run.runId from:lastDate];
        
        NSNumber *serverTime = [visDict objectForKey:@"serverTime"];
        NSNumber *currentTimeMillis = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000 )];
        NSNumber *delta = [NSNumber numberWithLongLong:(currentTimeMillis.longLongValue - serverTime.longLongValue)];
        
        [[NSUserDefaults standardUserDefaults] setObject:delta forKey:@"timeDelta"];
        
        if ([[visDict objectForKey:@"generalItemsVisibility"] count] > 0) {
            for (NSDictionary *viStatement in [visDict objectForKey:@"generalItemsVisibility"] ) {
                [GeneralItemVisibility visibilityWithDictionary:viStatement withRun:run];
            }
        }
        
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
        @autoreleasepool {
            NSDictionary *respDict = [ARLNetwork responsesForRun:run.runId]; // from:lastDate
            
            for (NSDictionary *response in [respDict objectForKey:@"responses"] ) {
                [Response responseWithDictionary:response inManagedObjectContext:self.context];
            }
        }
        if (serverTime) {
            [SynchronizationBookKeeping createEntry:@"generalItemsVisibility"
                                               time:serverTime
                                          idContext:run.runId
                             inManagedObjectContext:self.context];
        }
    }
}

- (void) synchronizeActions {
    NSLog(@"[%s]", __func__);
    
    @autoreleasepool {
        NSArray* actions =  [Action getUnsyncedActions:self.context];
        for (Action* action in actions) {
            [ARLNetwork publishAction:action.run.runId action:action.action itemId:action.generalItem.generalItemId time:action.time itemType:action.generalItem.type];
            action.synchronized = [NSNumber numberWithBool:YES];
        }
    }
    
    self.syncActions = NO;
}

- (void) synchronizeResponses {
    NSLog(@"[%s]", __func__);

//  BOOL uploads = NO;
    
    @autoreleasepool {
        NSArray* responses =  [Response getUnsyncedReponses:self.context];
        for (Response* resp in responses) {
            @autoreleasepool {
                if (resp.value) {
                    [ARLNetwork publishResponse:resp.run.runId responseValue:resp.value itemId:resp.generalItem.generalItemId timeStamp:resp.timeStamp];
                    resp.synchronized = [NSNumber numberWithBool:YES];
                } else {
                    u_int32_t random = arc4random();
                    NSString* imageName = [NSString stringWithFormat:@"%u.%@", random, resp.fileName];
                    
                    if (resp.run.runId) {
                        NSString* uploadUrl = [ARLNetwork requestUploadUrl:imageName withRun:resp.run.runId];
                        [ARLNetwork perfomUpload: uploadUrl withFileName:imageName contentType:resp.contentType withData:resp.data];
                        
                        NSString * serverUrl = [NSString stringWithFormat:@"%@/uploadService/%@/%@:%@/%@", serviceUrl, resp.run.runId,
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"],
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"],imageName];
                        NSDictionary *myDictionary;
                        
                        NSString * contentType;
                        if ([resp.contentType isEqualToString:@"audio/aac"]) contentType = @"audioUrl";
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
                        
                        [ARLNetwork publishResponse:resp.run.runId responseValue:jsonString itemId:resp.generalItem.generalItemId timeStamp:resp.timeStamp];
                        
                        resp.synchronized = [NSNumber numberWithBool:YES];
                        
                        //              uploads=YES;
                    }
                }
            }
        }
    }
    
//    if (uploads) {
//        [ARLFileCloudSynchronizer syncResponseData:self.context];
//    }
    
    self.syncResponses = NO;
}

@end
