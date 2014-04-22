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
    
    account.localId = [dict objectForKey:@"localId"];
    account.accountType = [dict objectForKey:@"accountType"];
    
    account.email = [dict objectForKey:@"email"];
    account.name= [dict objectForKey:@"name"];
    account.givenName = [dict objectForKey:@"givenName"];
    account.familyName = [dict objectForKey:@"familyName"];
    account.accountLevel= [dict objectForKey:@"accountLevel"];
    
    NSURL  *url = [NSURL URLWithString:[dict objectForKey:@"picture"]];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if (urlData) {
        account.picture = urlData;
    }
    
    NSError *error = nil;
    [context save:&error];
    if (error) {
        NSLog(@"[%s] error %@", __func__, error);
    }
    
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
