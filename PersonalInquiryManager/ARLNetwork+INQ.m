//
//  ARLNetwork+INQ.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLNetwork+INQ.h"

/*!
 *  Extends ARLNetwork with Inquiry specific methods.
 */
@implementation ARLNetwork (INQ)

/*!
 *  Fetch the JSON response of a REST service.
 *
 *  @param url The REST Service URL
 *
 *  @return The JSON Response.
 */
+ (id) returnJson: (NSString *) url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:applicationjson forHTTPHeaderField:accept];
    
    NSData *jsonData = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
    NSError *error = nil;
  
    return jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
}

/*!
 *  Return Friends of a User.
 *
 *  @param localId       The User oauth Id.
 *  @param oauthProvider The ouath Provider Id.
 *
 *  @return The Friends as JSON.
 */
+ (id) getFriends : (NSString *) localId withProviderId: (NSNumber *) oauthProvider {
    NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&oauthId=%@&oauthProvider=%@", elgUrl, @"user.friends", apiKey, localId,[self elggProviderId:oauthProvider]];
    return [self returnJson:url];
    
}

/*!
 *  Get the available Users.
 *
 *  @return The Users as JSON.
 */
+ (id) getUsers {
    #warning veg - 31-01-2014 Used elgUrl and apiKey constants.
    NSString * url = [NSString stringWithFormat:@"%@site.users&api_key=%@&minutes=44480", elgUrl, apiKey];
    return [self returnJson:url];}

/*!
 *  Return the Inquiries of a User.
 *
 *  @param localId       The User oauth Id.
 *  @param oauthProvider The ouath Provider Id.
 *
 *  @return The Inquiries as JSON.
 */
+ (id) getInquiries: (NSString *) localId withProviderId: (NSNumber *) oauthProvider {
    
    NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&oauthId=%@&oauthProvider=%@", elgUrl, @"user.inquiries", apiKey, localId,[self elggProviderId:oauthProvider]];
    return [self returnJson:url];
    
}

/*!
 *  Return the Hypothesis of an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The Hypothesis of the Inquiry as JSON.
 */
+ (id) getHypothesis:  (NSNumber *) inquiryId {
    NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.hypothesis", apiKey, inquiryId];
    NSLog(@"url %@", url);
    return [self returnJson:url];
    
}

/*!
 *  Return the Notes of an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The Notes of the Inquiry as JSON.
 */
+ (id) getNotes:  (NSNumber *) inquiryId {
    NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.notes", apiKey, inquiryId];
    return [self returnJson:url];
}

/*!
 *  Convert oauth provider id to a NSString.
 *
 *  @param oauthProvider the oauth provider id.
 *
 *  @return the name of the oauth provider.
 */
+ (NSString *) elggProviderId: (NSNumber *) oauthProvider {
    NSString * providerString;
    switch (oauthProvider.intValue) {
        case 1:
            providerString = @"Facebook";
            break;
        case 2:
            providerString = @"Google";
            break;
        case 3:
            providerString = @"LinkedIn";
            break;
        case 4:
            providerString = @"Twitter";
            break;
        default:
            break;
    }
    return providerString;
}

/*!
 *  Convert oauth Provider Name to Id.
 *
 *  @param oauthProvider oauthProvider the oauth provider name.
 *
 *  @return the id of the oauth provider.
 */
+ (NSNumber*) elggProviderByName: (NSString  *) oauthProvider {
    if ([oauthProvider isEqualToString:@"Facebook"]) {
        return [NSNumber numberWithInt:1];
    }
    if ([oauthProvider isEqualToString:@"Google"]) {
        return [NSNumber numberWithInt:2];
    }
    if ([oauthProvider isEqualToString:@"LinkedIn"]) {
        return [NSNumber numberWithInt:3];
    }
    if ([oauthProvider isEqualToString:@"Twitter"]) {
        return [NSNumber numberWithInt:4];
    }
    
    return nil;
}

/*!
 *  Return the ARLearn Run Id associated with an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The ARLearn RunId.
 */
+ (NSNumber *) getARLearnRunId: (NSNumber* ) inquiryId {
    NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.arlearnrun", apiKey, inquiryId];
    NSLog(@"url %@", url);
    NSLog(@"url %@", [self returnJson:url]);
    
    if (![[self returnJson:url] objectForKey:@"result"])
        #warning veg - 03-02-2014 Hardcoded Magic Number
        return [NSNumber numberWithInt:3639020];
    
    return [[self returnJson:url] objectForKey:@"result"];
}

/*!
 *  Return the ARLearn Game Id associated with an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The ARLearn GameId.
 */
+ (NSNumber *) getARLearnGameId: (NSNumber* ) inquiryId {
    NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.arlearngame", apiKey, inquiryId];
   
    if (![[self returnJson:url] objectForKey:@"result"])
        #warning veg - 03-02-2014 Hardcoded Magic Number
        return [NSNumber numberWithInt:3639020];
    
    return [[self returnJson:url] objectForKey:@"result"];
}


@end
