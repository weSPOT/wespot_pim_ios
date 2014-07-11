//
//  INQCloudSynchronizer.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQCloudSynchronizer.h"

@implementation INQCloudSynchronizer

/*!
 *  Synchronize Users with the backend.
 *
 *  @param context The Core Data Context.
 */
+ (void) syncUsers: (NSManagedObjectContext *) context {
    DLog(@"");
    
    INQCloudSynchronizer *synchronizer = [[INQCloudSynchronizer alloc] init];
  
    [synchronizer createContext:context];
    
    synchronizer.syncUsers = YES;
    
    [synchronizer sync];
}

/*!
 *  Synchronize Inquiries with the backend.
 *
 *  @param context The Core Data Context.
 */
+ (void) syncInquiries: (NSManagedObjectContext *) context {
    DLog(@"");
    
    INQCloudSynchronizer *synchronizer = [[INQCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncInquiries = YES;
    
    [synchronizer sync];
}

+ (void) syncInquiryUsers: (NSManagedObjectContext *) context inquiryId:(NSNumber *) inquiryId {
    DLog(@"");
    
    INQCloudSynchronizer *synchronizer = [[INQCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.inquiryId = inquiryId;
    synchronizer.syncInquiryUsers = YES;
    
    [synchronizer sync];
}

/*!
 *  Synchronize Messages with the backend.
 *
 *  @param context The Core Data Context.
 */
+ (void) syncMessages: (NSManagedObjectContext *) context inquiryId:(NSNumber *) inquiryId {
    DLog(@"");
    
    INQCloudSynchronizer *synchronizer = [[INQCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.inquiryId = inquiryId;
    synchronizer.syncMessages = YES;
    
    [synchronizer sync];
}

/*!
 *  Create a local Core Data Context.
 *
 *  @param mainContext The Parent Core Data Context.
 */
- (void) createContext: (NSManagedObjectContext *) mainContext {
    self.parentContext = mainContext;
    
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.context.parentContext = mainContext;
}

/*!
 *  Synchronize Asynchrone.
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
- (void)saveContext {
    NSError *error = nil;
    
    DLog(@"Saving NSManagedObjectContext");
    
    //#warning ABORT TEST CODE AHEAD
    //    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : @"DESCRIPTION" };
    //    
    //    error = [[NSError alloc] initWithDomain:@"DOMAIN" code:1 userInfo:errorDictionary];
    //
    //[ARLNetwork ShowAbortMessage:error func:[NSString stringWithFormat:@"%s",__func__]];
    
    if (self.context) {
        if ([self.context hasChanges]){
            if (![self.context save:&error]) {
                [ARLNetwork ShowAbortMessage:error func:[NSString stringWithFormat:@"%s",__func__]];
            }
        }
        
        if ([self.parentContext hasChanges]){
            [self.parentContext performBlock:^{
                NSError *error = nil;
                if (![self.parentContext save:&error]) {
                    [ARLNetwork ShowAbortMessage:error func:[NSString stringWithFormat:@"%s",__func__]];
                }
            }];
        }
    }
}

/*!
 *  The actual synchronize. 
 *
 *  Runs on a separate thread in the background.
 */
- (void) asyncExecution {
    mach_port_t machTID = pthread_mach_thread_np(pthread_self());
    DLog(@"Thread:0x%x - %@ - %@", machTID, @"Checking Lock", ARLAppDelegate.theLock);
    
    [ARLAppDelegate.theLock lock];
    
    DLog(@"Thread:0x%x - %@ - %@", machTID, @"Passed Lock", ARLAppDelegate.theLock);
    
     // DLog(@"Thread:0x%x - Start of INQ Synchronisation", machTID);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    while (ARLAppDelegate.SyncAllowed) {

        if (self.syncUsers) {
            [self syncAllUsers];
        } else if (self.syncInquiryUsers) {
            [self synchronizeInquiryUsers];
        } else if (self.syncMessages) {
            [self synchronizeMessages];
        } else if (self.syncInquiries) {
            [self syncronizeInquiries];
        } else {
            break;
        }
    }

    if (ARLAppDelegate.SyncAllowed) {
        [self saveContext];
        [NSThread sleepForTimeInterval:0.1];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [ARLAppDelegate.theLock unlock];
    
    DLog(@"Thread:0x%x - %@ - %@", machTID, @"Exit Lock", ARLAppDelegate.theLock);
    
    // DLog(@"Thread:0x%x - End of INQ Synchronisation", machTID);
}

/*!
 *  Syncronize Inquiries with backend.
 *
 *  Runs on a separate thread in the background.
 */
- (void) syncronizeInquiries{
    @autoreleasepool {
        id localId = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"];
        id providerId = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"];
        
        DLog(@"UserId=%@ providerId=%@", localId, providerId);
        
        NSDictionary *dict = [ARLNetwork getInquiries:localId withProviderId:providerId];
        
        if ([dict objectForKey:@"errorCode"]) {
            DLog( @"%@ - %@: %@", NSLocalizedString(@"Error", @"Error"), [dict objectForKey:@"errorCode"], [dict objectForKey:@"error"]);
        } else {
            //DLog(@"SyncronizeInquiries %@", [dict objectForKey:@"result"]);
            
            //******************************
            // Wipe records that no longer exist.
            //******************************
            
            // ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            NSArray *inquiries = [ARLAppDelegate retrievAllOfEntity:self.context enityName:@"Inquiry"];
            
            NSMutableSet *dbIds = [[NSMutableSet alloc] init];
            NSMutableSet *jsIds = [[NSMutableSet alloc] init];
            
            for (NSDictionary *inquiryDict in [dict objectForKey:@"result"]) {
                [jsIds addObject:[inquiryDict objectForKey:@"inquiryId"]];
            }
            
            for (Inquiry *inquiry in inquiries) {
                if (inquiry.inquiryId) {
                    [dbIds addObject:inquiry.inquiryId];
                }
            }
            
            [dbIds minusSet:jsIds];
            
            for (NSNumber *inquiryId in dbIds) {
                @autoreleasepool {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                              @"inquiryId = %@",
                                              inquiryId];
                    Inquiry *inquiry = [[ARLAppDelegate retrievAllOfEntity:self.context enityName:@"Inquiry" predicate:predicate] lastObject];
                    
                    DLog(@"Deleting Iqnquiry [%@] '%@'", inquiry.title, inquiry.inquiryId);
                    
#warning Also Remove all associated stuff?
                    
                    // Inquiry
                    //      Run
                    //          Action
                    //          CurrentItemVisibility / GeneralItem / GeneralItemData / GeneralItemVisibility
                    //          Message
                    //          Response
                    
                    if (inquiry) {
                        //            Run *run = inquiry.run;
                        //            if (run) {
                        //                [appDelegate.managedObjectContext deleteObject:run];
                        //            }
                        [self.context deleteObject:inquiry];
                    }
                }
            }
            
            if (dbIds.count>0) {
                [self.context save:nil];
            }
            
            //******************************
            // Update the remaining records.
            //******************************
            
            for (NSDictionary *inquiryDict in [dict objectForKey:@"result"]) {
                @autoreleasepool {
                    if (!ARLAppDelegate.SyncAllowed) {
                        break;
                    }
                    
                    Inquiry *newInquiry = [Inquiry inquiryWithDictionary:inquiryDict inManagedObjectContext:self.context];
                    
                    // DLog(@"InquiryId=%@", newInquiry.inquiryId);
                    
                    // REST CALL (costs time)!
                    id hypDict =[[ARLNetwork getHypothesis:newInquiry.inquiryId] objectForKey:@"result"];
                    if (hypDict) {
                        
                        if ([hypDict count] != 0) {
                            //DLog(@"Hypothesis Dictionary: %@", [hypDict objectAtIndex:0] );
                            NSString* hypString = [[hypDict objectAtIndex:0] objectForKey:@"description"];
                            if (hypString) {
                                newInquiry.hypothesis = hypString;
                            }
                        }
                    }
                    
                    //        id refDict =[[ARLNetwork getReflection:newInquiry.inquiryId] objectForKey:@"result"];
                    //        if (refDict) {
                    //
                    //            if ([refDict count] != 0) {
                    //                //DLog(@"Hypothesis Dictionary: %@", [hypDict objectAtIndex:0] );
                    //                NSString* refString = [[hypDict objectAtIndex:0] objectForKey:@"description"];
                    //                if (refString) {
                    //                    newInquiry.reflection = refString;
                    //                }
                    //            }
                    //        }
                    
                    // Get the correct Run for this Inquiry.
                    if (!newInquiry.run) {
                        NSNumber *runId = [ARLNetwork getARLearnRunId:newInquiry.inquiryId];
                        Run *selectedRun = [Run retrieveRun:runId inManagedObjectContext:self.context];
                        
                        if (!selectedRun) {
                            //3639020 get run from server
                            NSDictionary *rDict = [ARLNetwork runsWithId:runId];
                            
                            selectedRun = [Run runWithDictionary:rDict inManagedObjectContext:self.context];
                        }
                        
                        if (selectedRun) {
                            newInquiry.run = selectedRun;
                        }
                    }
                    
                    //#warning Syncing Messages must be made more inteligent.
                    //
                    //        if (newInquiry.run) {
                    //            //{
                    //            //    deleted = 0;
                    //            //    lastModificationDate = 1397566132526;
                    //            //    name = Default;
                    //            //    runId = 5300507992129536;
                    //            //    threadId = 5757904829284352;
                    //            //    type = "org.celstec.arlearn2.beans.run.Thread";
                    //            //}
                    //
                    //            NSDictionary *tDict = [ARLNetwork defaultThread:newInquiry.run.runId];
                    //            DLog(@"RunId: %@, ThreadId: %@", [tDict objectForKey:@"runId"], [tDict objectForKey:@"threadId"]);
                    //
                    //            NSDictionary *tmDict = [ARLNetwork defaultThreadMessages:newInquiry.run.runId];
                    //            NSArray *messages = (NSArray *)[tmDict objectForKey:@"messages"];
                    //
                    //            for (NSDictionary *mDict in messages)
                    //            {
                    //                Message *msg = [Message messageWithDictionary:mDict inManagedObjectContext:self.context];
                    //     
                    //                DLog(@"Body: %@", msg.body);
                    //            }
                    //        }
                    
                    NSError *error = nil;
                    [self.context save:&error];
                }
            }
        }
        
        // Sync ItemVisibility for inquiry
        NSArray *inquiries = [ARLAppDelegate retrievAllOfEntity:self.context enityName:@"Inquiry"];
        for (Inquiry *inquiry in inquiries) {
            if (ARLAppDelegate.SyncAllowed) {
                [ARLCloudSynchronizer syncVisibilityForInquiry:self.context run:inquiry.run];
            } else {
                break;
            }
        }
        
        if (ARLAppDelegate.SyncAllowed) {
            NSError *error = nil;
            [self.context save:&error];
        }
    }
    
    self.syncInquiries = NO;
}

/*!
 *  Syncronize Users (Friends) with backend.
 *
 *  Runs on a separate thread in the background.
 */
- (void) syncAllUsers {
    DLog(@"");
    
    @autoreleasepool {
        // Fetch Account default values for localId and withProviderId.
        NSDictionary *dict = [ARLNetwork getFriends:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"] withProviderId:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]];
        
        for (NSDictionary *user in [dict objectForKey:@"result"]) {
            if ( [((NSObject *)[user objectForKey:@"oauthProvider"]) isKindOfClass: [NSString class]]) {
                @autoreleasepool {
                    // veg - 03-02-2014 Are the oauthId/oauthProvider equal to the ones used to retrieve friends?
                    NSString* oauthId = [user objectForKey:@"oauthId"];
                    NSString* oauthProvider = [user objectForKey:@"oauthProvider"];
                    NSString* name = [user objectForKey:@"name"];
                    NSString* icon = [user objectForKey:@"icon"];
                    
                    //DLog(@"User: %@", user);
                    
                    // veg - 03-02-2014 Moved code below to ARLNetwork+INQ.m as utility method.
                    NSNumber * oauthProviderType = [ARLNetwork elggProviderByName:oauthProvider];
                    
                    [Account accountWithDictionary: [[NSDictionary alloc] initWithObjectsAndKeys:
                                                     icon, @"picture",
                                                     oauthId, @"localId",
                                                     oauthProviderType, @"accountType",
                                                     name, @"name", nil] inManagedObjectContext:self.context];
                }
                // #warning TESTACCOUNT CODE for Lazy Load Images.
                //            TestAccount *test =
                //            [TestAccount accountWithDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:
                //                                                icon, @"picture",
                //                                                oauthId, @"localId",
                //                                                oauthProviderType, @"accountType",
                //                                                name, @"name", nil] inManagedObjectContext:self.context];
                
                
                
                
                //            UIImage *tmp = [test lazyPicture];
                // DLog(@"Size: %0.0f x %0.0f", tmp.size.width, tmp.size.height);
            }
        }
    }
    
    self.syncUsers = NO;
}

/*!
 *  Synchronize Users (Friends) with backend.
 *
 *  Runs on a separate thread in the background.
 */
- (void) synchronizeInquiryUsers {
    DLog(@"InruiryId: %@", self.inquiryId);
    
    @autoreleasepool {
        Account * account = [ARLNetwork CurrentAccount];
        
        // Fetch Account default values for localId and withProviderId.
        NSDictionary *dict = [ARLNetwork getInquiryUsers:account.localId withProviderId:account.accountType inquiryId:self.inquiryId];
        
        for (NSDictionary *user in [dict objectForKey:@"result"]) {
            if ( [((NSObject *)[user objectForKey:@"oauthProvider"]) isKindOfClass: [NSString class]]) {
                @autoreleasepool {
                    Inquiry *inquiry = [Inquiry retrieveFromDbWithInquiryId:self.inquiryId withManagedContext:self.context];
                    
                    NSString *oauthProvider = [user objectForKey:@"oauthProvider"];
                    NSString *oauthProviderType = [NSString stringWithFormat:@"%@",[ARLNetwork elggProviderByName:oauthProvider]];
                    
                    // For non-existing users, download the full user info to create the Account record.
                    if (![Account retrieveFromDbWithLocalId:[user objectForKey:@"oauthId"] accountType:oauthProviderType withManagedContext:self.context]) {
                        NSDictionary *userInfo = [ARLNetwork getUserInfo:inquiry.run.runId
                                                                  userId:[user objectForKey:@"oauthId"]
                                                              providerId: oauthProviderType];
                        if (userInfo) {
                            [Account accountWithDictionary:userInfo inManagedObjectContext:self.context];
                        } else {
                            [Account accountWithDictionary:user inManagedObjectContext:self.context];
                        }
                    }
                }
            }
        }
    }
    
    self.syncInquiryUsers = NO;
}


/*!
 *  Synchronize Messages with backend.
 *
 *  Runs on a separate thread in the background.
 */
- (void) synchronizeMessages{
    DLog(@"InquiryIdId: %@", self.inquiryId);
    Inquiry *inquiry = [Inquiry retrieveFromDbWithInquiryId:self.inquiryId withManagedContext:self.context];
    
    NSDictionary *tmDict = [ARLNetwork defaultThreadMessages:inquiry.run.runId];
    NSArray *messages = (NSArray *)[tmDict objectForKey:@"messages"];
    
    for (NSDictionary *mDict in messages)
    {
        [Message messageWithDictionary:mDict inManagedObjectContext:self.context];
    }
    
    NSError *error = nil;
    [self.context save:&error];
    
    self.syncMessages = NO;
}

@end
