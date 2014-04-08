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
+ (void) syncUsers: (NSManagedObjectContext*) context {
    NSLog(@"[%s]", __func__);
    
    INQCloudSynchronizer* synchronizer = [[INQCloudSynchronizer alloc] init];
  
    [synchronizer createContext:context];
    
    synchronizer.syncUsers = YES;
    
    [synchronizer sync];
}

/*!
 *  Synchronize Inquiries with the backend.
 *
 *  @param context The Core Data Context.
 */
+ (void) syncInquiries: (NSManagedObjectContext*) context {
    NSLog(@"[%s]", __func__);
    
    INQCloudSynchronizer* synchronizer = [[INQCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncInquiries = YES;
    
    [synchronizer sync];
}


/*!
 *  Create a local Core Data Context.
 *
 *  @param mainContext The Parent Core Data Context.
 */
- (void) createContext: (NSManagedObjectContext*) mainContext {
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
- (void)saveContext{
    NSError *error = nil;
    
    if (self.context) {
        if ([self.context hasChanges]){
            if (![self.context save:&error]) {
                NSLog(@"[%s] Unresolved error %@, %@", __func__, error, [error userInfo]);
                abort();
            }
        }
        
        if ([self.parentContext hasChanges]){
//          NSLog(@"[%s] Saving Parent NSManagedObjectContext", __func__);
            [self.parentContext performBlock:^{
                NSError *error = nil;
                if (![self.parentContext save:&error]) {abort();}
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
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Checking Lock", ARLAppDelegate.theLock);
    
    [ARLAppDelegate.theLock lock];
    
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Passed Lock", ARLAppDelegate.theLock);
    
    NSLog(@"\r\n[%s 0x%x]\r\n*******************************************\r\nStart of INQ Synchronisation", __func__, machTID);

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    while (YES) {

        if (self.syncUsers) {
            [self syncAllUsers];
        } else if (self.syncInquiries) {
            [self syncronizeInquiries];
        } else {
            [self saveContext];
            break;
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [ARLAppDelegate.theLock unlock];
    
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Exit Lock", ARLAppDelegate.theLock);
    
    NSLog(@"\r\n[%s 0x%x] End of INQ Synchronisation\r\n*******************************************", __func__, machTID);
}

/*!
 *  Syncronize Inquiries with backend.
 *
 *  Runs on a separate thread in the background.
 */
- (void) syncronizeInquiries{
    id localId = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"];
    id providerId = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"];
    
    NSLog(@"[%s] userId=%@ providerId=%@", __func__, localId, providerId);
    
    NSDictionary *dict = [ARLNetwork getInquiries:localId withProviderId:providerId];
    
    //NSLog(@"[%s] syncronizeInquiries %@", __func__, [dict objectForKey:@"result"]);

    //******************************
    // Wipe records that no longer exist.
    //******************************
    
    // ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSArray *inquiries = [ARLAppDelegate retrievAllOfEntity:self.context/*appDelegate.managedObjectContext*/ enityName:@"Inquiry"];
    
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"inquiryId = %@",
                                  inquiryId];
        Inquiry *inquiry = [[ARLAppDelegate retrievAllOfEntity:self.context/*appDelegate.managedObjectContext*/ enityName:@"Inquiry" predicate:predicate] lastObject];
        
        NSLog(@"[%s] Deleting Iqnquiry [%@] '%@'", __func__, inquiry.title, inquiry.inquiryId);
        
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
            [self.context/*appDelegate.managedObjectContext*/ deleteObject:inquiry];
        }
    }
    
    if (dbIds.count>0) {
        [self.context/*appDelegate.managedObjectContext*/ save:nil];
    }
    
    //******************************
    // Update the remaining records.
    //******************************
    
    for (NSDictionary *inquiryDict in [dict objectForKey:@"result"]) {
        Inquiry *newInquiry = [Inquiry inquiryWithDictionary:inquiryDict inManagedObjectContext:self.context];

        // NSLog(@"[%s] inquiryId=%@", __func__, newInquiry.inquiryId);
   
        // REST CALL (costs time)!
        id hypDict =[[ARLNetwork getHypothesis:newInquiry.inquiryId] objectForKey:@"result"];
        if (hypDict) {

            if ([hypDict count] != 0) {
                //NSLog(@"[%s] hypDict %@",__func__, [hypDict objectAtIndex:0] );
                NSString* hypString = [[hypDict objectAtIndex:0] objectForKey:@"description"];
                if (hypString) {
                     newInquiry.hypothesis = hypString;
                }
            }
        }
        
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
        
        NSError *error = nil;
        [self.context save:&error];
    }
    
    self.syncInquiries = NO;
}

/*!
 *  Syncronize Users (Friends) with backend.
 *
 *  Runs on a separate thread in the background.
 */
- (void) syncAllUsers{
    NSLog(@"[%s]", __func__);
    
    // Fetch Account default values for localId and withProviderId.
    NSDictionary * dict = [ARLNetwork getFriends:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"] withProviderId:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]];
    
    for (NSDictionary *user in [dict objectForKey:@"result"]) {
        if ( [((NSObject *)[user objectForKey:@"oauthProvider"]) isKindOfClass: [NSString class]]) {
            
            // veg - 03-02-2014 Are the oauthId/oauthProvider equal to the ones used to retrieve friends?
            NSString* oauthId = [user objectForKey:@"oauthId"];
            NSString* oauthProvider = [user objectForKey:@"oauthProvider"];
            NSString* name = [user objectForKey:@"name"];
            NSString* icon = [user objectForKey:@"icon"];
            
            //NSLog(@"[%s] user %@", __func__, user);
            
            // veg - 03-02-2014 Moved code below to ARLNetwork+INQ.m as utility method.
            NSNumber * oauthProviderType = [ARLNetwork elggProviderByName:oauthProvider];
            
            [Account accountWithDictionary: [[NSDictionary alloc] initWithObjectsAndKeys:
                                             icon, @"picture",
                                             oauthId, @"localId",
                                             oauthProviderType, @"accountType",
                                             name, @"name", nil] inManagedObjectContext:self.context];
            
// #warning TESTACCOUNT CODE for Lazy Load Images.
//            TestAccount *test =
//            [TestAccount accountWithDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:
//                                                icon, @"picture",
//                                                oauthId, @"localId",
//                                                oauthProviderType, @"accountType",
//                                                name, @"name", nil] inManagedObjectContext:self.context];
            
            
            
            
//            UIImage *tmp = [test lazyPicture];
            // NSLog(@"%0.0f x %0.0f", tmp.size.width, tmp.size.height);
        }
    }
    
    self.syncUsers = NO;
}

@end
