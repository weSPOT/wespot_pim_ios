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
    if (self.syncUsers) {
        [self syncAllUsers];
        [self asyncExecution];
    } else if (self.syncInquiries) {
        [self syncronizeInquiries];
        [self asyncExecution];
    } else {
        [self saveContext];
    }
}

/*!
 *  Syncronize Inquiries with backend.
 *
 *  Runs on a separate thread in the background.
 */
- (void) syncronizeInquiries{
    NSLog(@"[%s]", __func__);

    NSDictionary * dict = [ARLNetwork getInquiries:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"] withProviderId:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]];
    
    //NSLog(@"[%s] syncronizeInquiries %@", __func__, [dict objectForKey:@"result"]);
    
    for (NSDictionary *inquiryDict in [dict objectForKey:@"result"]) {
        Inquiry* newInquiry = [Inquiry inquirytWithDictionary:inquiryDict inManagedObjectContext:self.context];
        
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
                                             icon, @"icon",
                                             oauthId, @"localId",
                                             oauthProviderType, @"accountType",
                                             name, @"name", nil] inManagedObjectContext:self.context];
        }
        
    }
    self.syncUsers = NO;
}

@end
