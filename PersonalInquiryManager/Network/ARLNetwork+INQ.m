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
 *  Fetch the JSON response of a REST service using GET.
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
  
//  [self dumpJsonData2:jsonData url:url];
    
    return jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
}

/*!
 *  Fetch the JSON response of a REST service using GET.
 *
 *  @param url The Base REST Service URL
 *  @param query The Query part of the REST Service URL
 
 *  @return The JSON Response.
 */
+ (id) returnJsonGET: (NSString *) url query:(NSString *) query {
    NSString *urlandquery = [[NSString alloc] initWithFormat:@"%@?%@", elgBaseUrl, query];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlandquery]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:applicationjson forHTTPHeaderField:accept];
    
    NSData *jsonData = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
    NSError *error = nil;
    
    //  [self dumpJsonData2:jsonData url:url];
    
    return jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
}

/*!
 *  Fetch the JSON response of a REST service using POST.
 *
 *  @param url The REST Service URL
 *  @parm body The REST Body.
 
 *  @return The JSON Response.
 */
+ (id) returnJsonPOST: (NSString *) url body:(NSString *) body {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:applicationjson forHTTPHeaderField:accept];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *jsonData = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
    NSError *error = nil;
    
    // [self dumpJsonData2:jsonData url:url];
    
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
//    NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&oauthId=%@&oauthProvider=%@", elgUrl, @"user.friends", apiKey, localId,[self elggProviderId:oauthProvider]];

    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"user.friends",                      @"method",
                          apiKey,                               @"api_key",
                          
                          localId,                              @"oauthId",
                          [self elggProviderId:oauthProvider],  @"oauthProvider",
                          
                          nil];
    
    return [self returnJson:[self dictionaryToUrl:dict]];
}

/*!
 *  Get the available Users.
 *
 *  @return The Users as JSON.
 */
+ (id) getUsers {
    // veg - 31-01-2014 Used elgUrl and apiKey constants.
    // NSString *url = [NSString stringWithFormat:@"%@site.users&api_key=%@&minutes=44480", elgUrl, apiKey];

    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"site.users",                        @"method",
                          apiKey,                               @"api_key",
                          
                          44480,                                @"minutes",
                          
                          nil];
    
//  NSString *url = [[NSString alloc] initWithFormat:@"%@?%@", elgBaseUrl, [ARLNetwork dictionaryToParmeters:dict]];
    
    return [self returnJson:[self dictionaryToUrl:dict]];
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
    //NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&oauthId=%@&oauthProvider=%@", elgUrl, @"user.inquiries", apiKey, localId, [self elggProviderId:oauthProvider]];
    
    // NSString *key = [[NSString alloc] initWithFormat:@"%@", apiKey];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"user.inquiries",                    @"method",
                          apiKey,                                  @"api_key",
                          
                          localId,                              @"oauthId",
                          [self elggProviderId:oauthProvider],  @"oauthProvider",
                          
                          nil];
    
//  NSString *url = [[NSString alloc] initWithFormat:@"%@?%@", elgBaseUrl, [ARLNetwork dictionaryToParmeters:dict]];
    
    return [self returnJson:[self dictionaryToUrl:dict]];
}

/*!
 *  Return the Hypothesis of an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The Hypothesis of the Inquiry as JSON.
 */
+ (id) getHypothesis:  (NSNumber *) inquiryId {
    //NSString *url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.hypothesis", apiKey, inquiryId];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.hypothesis",                @"method",
                          apiKey,                               @"api_key",
                          
                          inquiryId,                            @"inquiryId",
                          
                          nil];
    
//    NSString *url = [[NSString alloc] initWithFormat:@"%@?%@", elgBaseUrl, [ARLNetwork dictionaryToParmeters:dict]];
    
    return [self returnJson:[self dictionaryToUrl:dict]];
}

/*!
 *  Return the Notes of an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The Notes of the Inquiry as JSON.
 */
+ (id) getNotes:  (NSNumber *) inquiryId {
//  NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.notes", apiKey, inquiryId];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.notes",                     @"method",
                          apiKey,                               @"api_key",
                          
                          inquiryId,                            @"inquiryId",
                          
                          nil];
    
    return [self returnJson:[self dictionaryToUrl:dict]];
}

/*!
 *  See http://trac.wespot.net/wiki/API%20ELGG
 *
 *  @return <#return value description#>
 */
+ (id) createInquiry: (NSString *)title description: (NSString *)description {
    Account *account = [ARLNetwork CurrentAccount];
    
    NSString *user_uid = [[NSString alloc] initWithFormat:@"%@_%@",[ARLNetwork elggProviderId:account.accountType], account.localId];
    NSString *provider = [ARLNetwork elggProviderId:account.accountType];
//  NSString *key = [[NSString alloc] initWithFormat:@"%@", apiKey];
  
    NSString *encoded = [ARLNetwork htmlEncode:description];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.create",        @"method",                
                          apiKey,                   @"api_key",
                          
                          title,                    @"name",
                          encoded,                  @"description",
                          @"Interests",             @"interests",                               //(Tags, comma separated)
                          @"2",                     @"membership",                              //(Membership: 0 -> Closed, 2 -> Open)
                          @"1",                     @"vis",                                     //(Visibility: 0 -> Inquiry members only, 1 -> logged in users, 2 -> Public)
                          @"ye",                    @"wespot_arlearn_enable",                   //(Enable ARLearn for Data Collection: Yes/No)
                          @"no",                    @"group_multiple_admin_allow_enable",       //(Allow multiple admins: Yes/No)
                          
                          provider,                 @"provider",                                //@"Google"
                          user_uid,                 @"user_uid",                                //@"Google_localId",
                          
                          nil];

    NSString *body = [ARLNetwork dictionaryToParmeters:dict];
    
    NSString *url = elgBaseUrl;
    
    return [self returnJsonPOST:url body:body];
}

+ (NSString *) htmlEncode:(NSString *)html {
    NSString *encoded = [[NSString alloc] initWithFormat:@"%@",CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)html, NULL, CFSTR("!$&'()*+,-./:;=?@_~<>"), kCFStringEncodingUTF8)];
   return encoded;
}
/*!
 *  Create a URL encoded list based on the dictionary.
 *
 *  @param dict The dictionairy.
 *
 *  @return The encoded string.
 */
+ (NSString *) dictionaryToParmeters:(NSDictionary *)dict {
    NSMutableString *url = [[NSMutableString alloc] init];
    
    for (NSString * key in dict) {
        url = [[NSMutableString alloc ] initWithString:[url stringByAppendingFormat:@"%@%@=%@", ([url length] == 0)?@"":@"&", key, [dict objectForKey: key]]];
    }
    
    return url;
}


/*!
 *  Create a URL with a URL encoded list pf parameters based on the dictionary.
 *
 *  @param dict The dictionairy.
 *
 *  @return The Url with its parameters.
 */
+ (NSString *) dictionaryToUrl:(NSDictionary *)dict {
    return [[NSMutableString alloc] initWithFormat:@"%@?%@", elgBaseUrl, [ARLNetwork dictionaryToParmeters:dict]];
}

/*!
 *  Return the Files of an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The Files of the Inquiry as JSON.
 */
+ (id) getFiles:  (NSNumber *) inquiryId {
    NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.files", apiKey, inquiryId];
    
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
+ (NSNumber *) getARLearnRunId: (NSNumber *) inquiryId {
    NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.arlearnrun", apiKey, inquiryId];
 
//    NSLog(@"[%s] url %@", __func__, url);
//    NSLog(@"[%s]url %@", __func__, [self returnJson:url]);
    
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

/*!
 *  Returns YES if logged-in.
 *
 *  @return YES if logged-in.
 */
+ (BOOL)isLoggedIn {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    Account *account = ARLNetwork.CurrentAccount;

    if (account && [appDelegate performSelector:@selector(isLoggedIn)]) {
        return [appDelegate performSelector:@selector(isLoggedIn) withObject: nil]== [NSNumber numberWithBool:YES];
    }
    
    return NO;
}

/*!
 *  Returns the current account (or nil).
 *
 *  @return the current account.
 */
+ (Account *) CurrentAccount {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if ([appDelegate performSelector:@selector(CurrentAccount)]) {
        return [appDelegate performSelector:@selector(CurrentAccount) withObject:nil];
    }
    
    return nil;
}

/*!
 *  Returns YES if a wifi connection is available.
 *
 *  @return YES if wifi is there.
 */
+ (BOOL)networkAvailable {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSNumber *result = nil;
    
    if ([appDelegate performSelector:@selector(networkAvailable)]) {
        result = [appDelegate performSelector:@selector(networkAvailable) withObject: nil];
    }
   
    if (result) {
        return result == [NSNumber numberWithBool:YES];
    }
    
    return YES;
}

@end
