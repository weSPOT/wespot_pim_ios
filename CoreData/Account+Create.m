//
//  Account+Test.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/24/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "Account+Create.h"

@implementation Account (Create)

/*!
 *  Retrieve or create an account using a NSDictionary.
 *
 *  @param dict    Should at least contain localId, accountType, email, name, givenName, familyName, accountLevel. Optional is picture.
 *  @param context <#context description#>
 *
 *  @return <#return value description#>
 */
+ (Account *) accountWithDictionary: (NSDictionary *) dict inManagedObjectContext: (NSManagedObjectContext * ) context {
    Account * account = [self retrieveFromDb:dict withManagedContext:context];
    
    if (!account) {
        account = [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:context];
    }
    
// Also support:
//    {
//        icon = "http://inquiry.wespot.net/mod/profile/icondirect.php?lastcache=1396854990&joindate=1396854975&guid=32309&size=medium"; -> ok
//        name = "Stefaan Ternier";    -> ok
//        oauthId = "stefaan.ternier"; -> email?
//        oauthProvider = weSPOT;      -> ok
//    }
    
    if ([dict objectForKey:@"accountType"]) {
        account.localId = [dict objectForKey:@"localId"];
    } else if ([dict objectForKey:@"oauthId"]) {
        account.localId = [dict objectForKey:@"oauthId"];
    }
    
    if ([dict objectForKey:@"accountType"]) {
        account.accountType = [dict objectForKey:@"accountType"];
    } else if ([dict objectForKey:@"oauthProvider"]) {
        account.accountType = [ARLNetwork elggProviderByName:[dict objectForKey:@"oauthProvider"]];
    }
    
    account.email = [dict objectForKey:@"email"];
    account.name= [dict objectForKey:@"name"];
    account.givenName = [dict objectForKey:@"givenName"];
    account.familyName = [dict objectForKey:@"familyName"];
    account.accountLevel= [dict objectForKey:@"accountLevel"];
    
    NSURL *url = [NSURL URLWithString:[dict objectForKey:[dict objectForKey:@"picture"] ? @"picture": @"icon"]];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if (urlData) {
        account.picture = urlData;
    }
    
    [INQLog SaveNLog:context];
    
    return account;
}

/*!
 *  Retrieve from Database using a NSDictionary.
 *
 *  @param dict    Should at least contain localId and accountType.
 *  @param context <#context description#>
 *
 *  @return <#return value description#>
 */
+ (Account *) retrieveFromDb: (NSDictionary *) dict withManagedContext: (NSManagedObjectContext*) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];

    request.predicate = [NSPredicate predicateWithFormat:@"(localId = %@) AND (accountType = %d)", [dict objectForKey:@"localId"], [[dict objectForKey:@"accountType"] intValue]];
    
    NSArray *accountsFromDb = [context executeFetchRequest:request error:nil];
    
    if (!accountsFromDb || ([accountsFromDb count] != 1)) {
        return nil;
    } else {
        return [accountsFromDb lastObject];
    }
}

/*!
 *  Retrieve from Database using the localId.
 *
 *  @param localId The localId of the user account to retrieve.
 *  @param context <#context description#>
 *
 *  @return <#return value description#>
 */
+ (Account *) retrieveFromDbWithLocalId: (NSString *) localId accountType: (NSString *) accountType withManagedContext: (NSManagedObjectContext*) context {
    Account * account = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(localId = %@) AND (accountType = %d)", localId, [accountType intValue]];
    
    NSArray *accountsFromDb = [context executeFetchRequest:request error:nil];
    
    if (!accountsFromDb || ([accountsFromDb count] != 1)) {
        return nil;
    } else {
        account = [accountsFromDb lastObject];
        return account;
    }
}

@end
