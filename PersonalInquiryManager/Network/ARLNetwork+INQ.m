//
//  ARLNetwork+INQ.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLNetwork+INQ.h"

@interface ARLNetwork()

@end

/*!
 *  Extends ARLNetwork with Inquiry specific methods.
 */
@implementation ARLNetwork (INQ)

/*!
 *  Getter for elgUrl property.
 *
 *  @return the correct base Url for calling json methods (including ?method=).
*/

//+(NSString *) elgUrl __attribute__((deprecated)) {
//    return [self.elgBaseUrl stringByAppendingString:@"?method="];
//}

/*!
 *  Getter for elgUrl property.
 *
 *  @return the correct base Url for calling json methods.
 */
+(NSString *) elgBaseUrl {
    NSString *Result = @"http://streetlearn.appspot.com/rest/ElggProxy";
    switch (self.elgUseProxy) {
        case TRUE:
            switch (self.elgDeveloperMode) {
                case TRUE:
                    Result = @"http://streetlearn.appspot.com/rest/ElggProxy/dev";
                    break;
                case FALSE:
                     Result = @"http://streetlearn.appspot.com/rest/ElggProxy";
                    break;
            }
            break;
        case FALSE:
            switch (self.elgDeveloperMode) {
                case TRUE:
                    Result = @"http://dev.inquiry.wespot.net/services/api/rest/json/";
                    break;
                case FALSE:
                    Result = @"http://inquiry.wespot.net/services/api/rest/json/";
                    break;
            }
            break;
    }
    
    return Result;
}

+(BOOL) elgDeveloperMode {
    return [[NSUserDefaults standardUserDefaults] boolForKey:DEVELOPMENT_MODE];
}

+(BOOL) elgUseProxy {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PROXY_MODE];
}

+(NSInteger *) defaultInquiryVisibility {
    return [[NSUserDefaults standardUserDefaults] integerForKey:INQUIRY_VISIBILITY];
}

+(NSInteger *) defaultInquiryMembership {
    return [[NSUserDefaults standardUserDefaults] integerForKey:INQUIRY_MEMBERSHIP];
}

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
    
    if (self.elgUseProxy) {
        NSString * authorizationString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"]];
        [request setValue:authorizationString forHTTPHeaderField:@"Authorization"];
    }
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    
    @try {
        NSError *error  = nil;
        NSData *jsonData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
        ELog(error);
        
        if (response.statusCode!=200) {
            DLog(@"%@ %ld", response.URL, (long)(response.statusCode));
        }
        
        error = nil;
        
        //  [self dumpJsonData2:jsonData url:url];
        
        return jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    }
    @catch (NSException *exception) {
        Log(@"Exception:%@",exception);
        
        return nil;
    }
}

/*!
 *  Fetch the JSON response of a REST service using GET.
 *
 *  @param url The Base REST Service URL
 *  @param query The Query part of the REST Service URL
 
 *  @return The JSON Response.
 */
+ (id) returnJsonGET: (NSString *) url query:(NSString *) query {
    NSString *urlandquery = [NSString stringWithFormat:@"%@?%@", ARLNetwork.elgBaseUrl, query];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlandquery]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:applicationjson forHTTPHeaderField:accept];
    
    if (self.elgUseProxy) {
        NSString * authorizationString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"]];
        [request setValue:authorizationString forHTTPHeaderField:@"Authorization"];
    }
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    
    NSError *error = nil;
    NSData *jsonData = [ NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    ELog(error);
    
    if (response.statusCode!=200) {
        DLog(@"%@ %ld", response.URL, (long)response.statusCode);
    }
    
    error = nil;
    
    //[self dumpJsonData2:jsonData url:url];
    
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
    
    if (self.elgUseProxy) {
        NSString * authorizationString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"]];
        [request setValue:authorizationString forHTTPHeaderField:@"Authorization"];
    }
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    
    NSError *error = nil;
    NSData *jsonData = [ NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    ELog(error);
    
    if (response.statusCode!=200) {
        DLog(@"%@ %ld", response.URL, (long)response.statusCode);
    }
    
    error = nil;
    
    //[self dumpJsonData2:jsonData url:url];
    
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
    
    DLog(@"%@", url);
    DLog(@"%@", jsonString);
}

/*!
 *  Return Friends of a User.
 *
 *  @param localId       The User oauth Id.
 *  @param oauthProvider The ouath Provider Id.
 *
 *  @return The Friends as JSON.
 */
+ (id) getFriends: (NSString *) localId withProviderId: (NSNumber *) oauthProvider {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"user.friends",                      @"method",
                          apiKey,                               @"api_key",
                          
                          localId,                              @"oauthId",
                          [self elggProviderId:oauthProvider],  @"oauthProvider",
                          
                          nil];
    
    return [self returnJson:[self dictionaryToUrl:dict]];
}

/*!
 *  Get the Users of an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The Users as JSON.
 */
+ (id) getInquiryUsers: (NSString *) localId withProviderId: (NSNumber *) oauthProvider inquiryId: (NSNumber *) inquiryId {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.users",                     @"method",
                          apiKey,                               @"api_key",
                          
                          inquiryId,                            @"inquiryId",
                  
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
    NSNumber *minutes =[NSNumber numberWithInt:44480];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"site.users",                        @"method",
                          apiKey,                               @"api_key",
                          
                          minutes,                              @"minutes",
                          
                          nil];

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
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"user.inquiries",                    @"method",
                          apiKey,                               @"api_key",
                          
                          localId,                              @"oauthId",
                          [self elggProviderId:oauthProvider],  @"oauthProvider",
                          
                          nil];
    
    return [self returnJson:[self dictionaryToUrl:dict]];
}

/*!
 *  Return the Hypothesis of an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The Hypothesis of the Inquiry as JSON.
 */
+ (id) getHypothesis: (NSNumber *) inquiryId {
    // NSString *url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.hypothesis", apiKey, inquiryId];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.hypothesis",                @"method",
                          apiKey,                               @"api_key",
                          
                          inquiryId,                            @"inquiryId",
                          
                          nil];

    return [self returnJson:[self dictionaryToUrl:dict]];
}

/*!
 *  Return the Questions of an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The Questions of the Inquiry as JSON.
 */
+ (id) getQuestions: (NSNumber *) inquiryId {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.questions",                 @"method",
                          apiKey,                               @"api_key",
                          
                          inquiryId,                            @"inquiryId",
                          
                          nil];

    return [self returnJson:[self dictionaryToUrl:dict]];
}

/*!
 *  Return the Answers of an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The Answers of the Inquiry as JSON.
 */
+ (id) getAnswers: (NSNumber *) inquiryId {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.answers",                   @"method",
                          apiKey,                               @"api_key",
                          
                          inquiryId,                            @"inquiryId",
                          
                          nil];
    
    return [self returnJson:[self dictionaryToUrl:dict]];
}

/*!
 *  Return the Reflection of an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The Reflection of the Inquiry as JSON.
 */
+ (id) getReflection:  (NSNumber *) inquiryId {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.reflection",                @"method",
                          apiKey,                               @"api_key",
                          
                          inquiryId,                            @"inquiryId",
                          
                          nil];
    
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
+ (id) createInquiry: (NSString *)title description: (NSString *)description visibility: (NSNumber *)visibility membership: (NSNumber *)membership {
    Account *account = [ARLNetwork CurrentAccount];
    
    NSString *user_uid = [NSString stringWithFormat:@"%@", account.localId];
    NSString *provider = [ARLNetwork elggProviderId:account.accountType];
  
    NSString *encoded = [ARLNetwork htmlEncode:description];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.create",        @"method",
                          apiKey,                   @"api_key",
                          
                          title,                    @"name",
                          encoded,                  @"description",
                          @"Interests",             @"interests",                               //(Tags, comma separated)
                          membership,               @"membership",                              //(Membership: 0 -> Closed, 2 -> Open)
                          visibility,               @"vis",                                     //(Visibility: 0 -> Inquiry members only, 1 -> logged in users, 2 -> Public)
                          @"yes",                   @"wespot_arlearn_enable",                   //(Enable ARLearn for Data Collection: Yes/No)
                          @"no",                    @"group_multiple_admin_allow_enable",       //(Allow multiple admins: Yes/No)
                          
                          provider,                 @"provider",                                //@"Google"
                          user_uid,                 @"user_uid",                                //@"Google_localId",
                          
                          nil];

    NSString *body = [ARLNetwork dictionaryToParmeters:dict];
    
    NSString *url = ARLNetwork.elgBaseUrl;
    
    return [self returnJsonPOST:url body:body];
}

+ (NSString *) htmlEncode:(NSString *)html {
   return [NSString stringWithFormat:@"%@",CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)html, NULL, CFSTR("!$&'()*+,-./:;=?@_~<>"), kCFStringEncodingUTF8)];
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
        url = [NSMutableString stringWithString:[url stringByAppendingFormat:@"%@%@=%@", ([url length] == 0)?@"":@"&", key, [dict objectForKey: key]]];
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
+ (NSString *) dictionaryToUrl: (NSDictionary *)dict {
    NSString *url = [NSString stringWithFormat:@"%@?%@", ARLNetwork.elgBaseUrl, [ARLNetwork dictionaryToParmeters:dict]];
    
    // DLog(@"%@", url);
    
    return url;
}

/*!
 *  Return the Files of an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The Files of the Inquiry as JSON.
 */
+ (id) getFiles: (NSNumber *) inquiryId {
    // NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.files", apiKey, inquiryId];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.files",                     @"method",
                          apiKey,                               @"api_key",
                          
                          inquiryId,                            @"inquiryId",
                          
                          nil];
    
    return [self returnJson:[self dictionaryToUrl:dict]];
}

/*!
 *  Return the Schools.
 *
 *  @return The Schools as JSON.
 */
+ (id) getSchools {
    return [self returnJson:@"https://wespot-arlearn.appspot.com/oauth/school/schools"];
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
        case INTERNAL:
            providerString = @"0";
            break;
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
+ (NSNumber *) elggProviderByName: (NSString *) oauthProvider {
    NSString *tmp = [NSString stringWithFormat:@"%@", oauthProvider];
    
    if ([tmp isEqualToString:@"0"]) {
        return [NSNumber numberWithInt:INTERNAL];
    }
    
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
    // NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.arlearnrun", apiKey, inquiryId];
 
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.arlearnrun",                @"method",
                          apiKey,                               @"api_key",
                          
                          inquiryId,                            @"inquiryId",
                          
                          nil];
    
    NSDictionary *result = [self returnJson:[self dictionaryToUrl:dict]];
    
    if (![result objectForKey:@"result"]) {
        return [NSNumber numberWithInt:MISSING_ID];
    }
    
    return [result objectForKey:@"result"];
}

/*!
 *  Return the ARLearn Game Id associated with an Inquiry.
 *
 *  @param inquiryId The Inquiry Id.
 *
 *  @return The ARLearn GameId.
 */
+ (NSNumber *) getARLearnGameId: (NSNumber* ) inquiryId {
    // NSString * url = [NSString stringWithFormat:@"%@%@&api_key=%@&inquiryId=%@", elgUrl, @"inquiry.arlearngame", apiKey, inquiryId];
   
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"inquiry.arlearngame",               @"method",
                          apiKey,                               @"api_key",
                          
                          inquiryId,                            @"inquiryId",
                          
                          nil];
    
    NSDictionary *result = [self returnJson:[self dictionaryToUrl:dict]];

    if (![result objectForKey:@"result"]) {
        return [NSNumber numberWithInt:MISSING_ID];
    }
    
    return [result objectForKey:@"result"];
}

/*!
 *  Returns YES if logged-in.
 *
 *  @return YES if logged-in.
 */
+ (BOOL)isLoggedIn {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    Account *account = ARLNetwork.CurrentAccount;

    if (account && [appDelegate respondsToSelector:@selector(isLoggedIn)]) {
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
    
    if ([appDelegate respondsToSelector:@selector(CurrentAccount)]) {
        return [appDelegate performSelector:@selector(CurrentAccount) withObject:nil];
    }
    
    return nil;
}

+ (void)ShowAbortMessage: (NSString *) title message:(NSString *) message {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // See http://stackoverflow.com/questions/3753154/make-uialertview-blocking
    //NSRunLoop *run_loop = [NSRunLoop currentRunLoop];
    
    if ([appDelegate respondsToSelector:@selector(ShowAbortMessage:message:)]) {
        [appDelegate performSelector:@selector(ShowAbortMessage:message:) withObject:title withObject:message];
    }
    
    // Lock the Condition
    [ARLAppDelegate.theAbortLock lock];
    
    //WARNING: Only do this if not the MainThread.
    if (![NSThread isMainThread]) {
        
        // We wait until OK on the UIAlertView is tapped and provides a Signal to continue.
        [ARLAppDelegate.theAbortLock wait];
        
        // Unlock the Condition also when we exit.
        [ARLAppDelegate.theAbortLock unlock];
        
        [NSThread exit];
    } else {
        // Unlock the Condition when we're not running on the mainthread.
        [ARLAppDelegate.theAbortLock unlock];
    }
}

+ (void)ShowAbortMessage: (NSError *) error func:(NSString *)func {
    
    NSString *msg = [NSString stringWithFormat:@"%@\n\nUnresolved error code %ld,\n\n%@", func, (long)[error code], [error localizedDescription]];
    
     [ARLNetwork ShowAbortMessage:NSLocalizedString(@"Error", @"Error")
                         message:msg];
}

/*!
 *  Returns YES if a wifi connection is available.
 *
 *  @return YES if wifi is there.
 */
+ (BOOL) networkAvailable {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSNumber *result = nil;
    
    if ([appDelegate respondsToSelector:@selector(networkAvailable)]) {
        result = [appDelegate performSelector:@selector(networkAvailable) withObject: nil];
    }
   
    if (result && [result boolValue]) {
        //WARNING: DEBUG CODE (Change to NO for debugging off-line code).
        return YES;
    }
    
    return NO;
}

//+ (NSDictionary *) addQuestionWithDictionary:(NSString *)name description:(NSString *)description {
//    NSString *url = ARLNetwork.elgBaseUrl;
//
//    return [self addQuestion:[ARLNetwork dictionaryToParmeters:question]];
//}

+ (id) addQuestionWithDictionary:(NSString *)title
                     description:(NSString *)description
                            tags:(NSString *)tags
                       inquiryId:(NSNumber *)inquiryId
{
    Account *account = [ARLNetwork CurrentAccount];
    
    NSString *user_uid = [NSString stringWithFormat:@"%@", account.localId];
    NSString *provider = [ARLNetwork elggProviderId:account.accountType];
    
    NSString *encoded = [ARLNetwork htmlEncode:description];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"add.question",          @"method",
                          apiKey,                   @"api_key",
                          
                          title,                    @"name",
                          encoded,                  @"description",
                          inquiryId,                @"container_guid",
                          tags,                     @"tags",                //(Tags, comma separated)
                          
                          // membership,            @"access_id",           //(Read Access: 0 -> Private, 1 -> Logged In, 2 -> Public)
                          // membership,            @"write_access_id",     //(Write Access: 0 -> Private, 1 -> Logged In, 2 -> Public)

                          provider,                 @"provider",            //@"Google"
                          user_uid,                 @"user_uid",            //@"Google_localId",
                          
                          nil];
    
    // Log(@"%@", dict);
    
    NSString *body = [ARLNetwork dictionaryToParmeters:dict];
   
    // Log(@"%@", body);
    
    // Angel:
    // method=add.question&
    // name=test&
    // description=tesd+descr&
    // container_guid=42876&
    // provider=Google&
    // user_uid=117769871710404943583&
    // tags=tag&
    // api_key=27936b77bcb9bb67df2965c6518f37a77a7ab9f8
    
    // iOS
    // description=%27question%201&
    // container_guid=62226&
    // name=Question&
    // api_key=27936b77bcb9bb67df2965c6518f37a77a7ab9f8&
    // method=add.question&
    // user_uid=103021572104496509774&
    // provider=Google
    
    NSString *url = ARLNetwork.elgBaseUrl;
    
    return [self returnJsonPOST:url body:body];
}

//+ (NSDictionary *) addQuestionWithDictionary:(NSString *)name description:(NSString *)description {
//    NSString *url = ARLNetwork.elgBaseUrl;
//
//    return [self addQuestion:[ARLNetwork dictionaryToParmeters:question]];
//}

+ (id) deleteQuestionWithDictionary:(NSNumber *)questionId
{
    Account *account = [ARLNetwork CurrentAccount];
    
    NSString *user_uid = [NSString stringWithFormat:@"%@", account.localId];
    NSString *provider = [ARLNetwork elggProviderId:account.accountType];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"remove.object",         @"method",
                          apiKey,                   @"api_key",
                          
                          questionId,               @"objectId",
                          
                          provider,                 @"provider",            //@"Google"
                          user_uid,                 @"user_uid",            //@"Google_localId",
                          
                          nil];
    
    NSString *body = [ARLNetwork dictionaryToParmeters:dict];

    NSString *url = ARLNetwork.elgBaseUrl;
    
    return [self returnJsonPOST:url body:body];
}

@end
