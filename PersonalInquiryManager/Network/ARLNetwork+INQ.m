//
//  ARLNetwork+INQ.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLNetwork+INQ.h"
//#import <SystemConfiguration/SystemConfiguration.h>

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
  
    [self dumpJsonData2:jsonData url:url];
    
    return jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
}

/*!
 *  Renamed to avoid linking warnings with ARLNetwork.h
 *
 *  @param jsonData <#jsonData description#>
 *  @param url      <#url description#>
 */
+(void) dumpJsonData2: (NSData *) jsonData url: (NSString *) url {
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"\r\n\r\n[%s]\r\n%@\r\n%@\r\n\r\n", __func__, url, jsonString);
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
    // veg - 31-01-2014 Used elgUrl and apiKey constants.
    NSString * url = [NSString stringWithFormat:@"%@site.users&api_key=%@&minutes=44480", elgUrl, apiKey];

    return [self returnJson:url];
}

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
        case FACEBOOK:
            providerString = @"Facebook";
            break;
        case GOOGLE:
            providerString = @"Google";
            break;
        case LINKEDIN:
            providerString = @"LinkedIn";
            break;
        case TWITTER:
            providerString = @"Twitter";
            break;
        case WESPOT:
            providerString = @"weSPOT";
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
        return [NSNumber numberWithInt:FACEBOOK];
    }
    if ([oauthProvider isEqualToString:@"Google"]) {
        return [NSNumber numberWithInt:GOOGLE];
    }
    if ([oauthProvider isEqualToString:@"LinkedIn"]) {
        return [NSNumber numberWithInt:LINKEDIN];
    }
    if ([oauthProvider isEqualToString:@"Twitter"]) {
        return [NSNumber numberWithInt:TWITTER];
    }
    if ([oauthProvider isEqualToString:@"weSPOT"]) {
        return [NSNumber numberWithInt:WESPOT];
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

typedef void(^connection)(BOOL);

+ (void)checkInternet:(connection)block
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"]];
    request.HTTPMethod = @"HEAD";
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    request.timeoutInterval = 10.0;
    
    [NSURLConnection
        sendAsynchronousRequest:request
        queue:[NSOperationQueue mainQueue]
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
             {
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 
                 block([(NSHTTPURLResponse *)response statusCode] == 200);
             }];
}

//+ (BOOL)checkNet {
//    
//    [self checkInternet:^(connection internet)
//    {
//         
////    Reachability *netStatus=[Reachability reachabilityWithHostname:@"www.google.com"];
////    
//         if (internet)
//         {
//             // "Internet" aka Google
//             return YES;
//         }
//         else
//         {
//             // No "Internet" aka no Google
//             
//             return NO;
//         }
//         
//         // ([netStatus currentReachabilityStatus] == NotReachable){
//        return NO;
//    }];
//}

/*!
 *  Test if we're online by probing google.
 *
 *  NOTE this method is called to often and should do a HEAD instead of GET.
 *  NOTE Reachability related code will not compile due to syntax problems in socket.h.
 *
 *  @return <#return value description#>
 */
+ (BOOL)connectedToNetwork
{
    NSError *error = nil;
    
    return ([NSString
             stringWithContentsOfURL:[NSURL
                                        URLWithString:@"http://www.google.com"]
                                        encoding:NSUTF8StringEncoding
                                        error:&error]!=NULL)?YES:NO;
}

@end