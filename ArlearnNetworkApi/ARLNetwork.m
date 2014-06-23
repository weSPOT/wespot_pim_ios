 //
//  ARLNetwork.m
//  ARLearn
//
//  Created by Stefaan Ternier on 1/12/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLNetwork.h"

@implementation ARLNetwork

#pragma mark - Network Requests

+ (NSMutableURLRequest *) prepareRequest: (NSString *) method requestWithUrl: (NSString *) url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:method];
    [request setValue:applicationjson forHTTPHeaderField:accept];
    
    return request;
}

+ (id) executeARLearnGetWithAuthorization: (NSString *) path {
    NSString *urlString = [NSString stringWithFormat:@"%@/rest/%@", serviceUrl, path];
    
    // DLog(@"%@", urlString);
    
    NSMutableURLRequest *request = [self prepareRequest:@"GET" requestWithUrl:urlString];
    
    NSString * authorizationString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"]];
    [request setValue:authorizationString forHTTPHeaderField:@"Authorization"];
    
    NSData *jsonData = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
    NSError *error = nil;
    
    // [self dumpJsonData:jsonData url:urlString];
    
    return jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
}

+ (id) executeARLearnPostWithAuthorization: (NSString *) path
                                  postData:(NSData *) data
                           withContentType: (NSString *) ctValue {
    NSString* urlString = [NSString stringWithFormat:@"%@/rest/%@", serviceUrl, path];
    NSMutableURLRequest *request = [self prepareRequest:@"POST" requestWithUrl:urlString];
    
    NSString * authorizationString = [NSString stringWithFormat:@"GoogleLogin auth=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"]];
    [request setValue:authorizationString forHTTPHeaderField:@"Authorization"];
    
    [request setHTTPBody:data];
    if (ctValue) [request setValue:ctValue forHTTPHeaderField:contenttype];

    NSData *jsonData = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
    NSError *error = nil;

    // [self dumpJsonData:jsonData url:urlString];
    
    return jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
}

+ (id) executeARLearnGet: (NSString *) path {
    NSString* urlString = [NSString stringWithFormat:@"%@/rest/%@", serviceUrl, path];
    NSMutableURLRequest *request = [self prepareRequest:@"GET" requestWithUrl:urlString];
    NSData *jsonData = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
    NSError *error = nil;
  
    // [self dumpJsonData:jsonData url:urlString];
    
    return jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
}

+ (id) executeARLearnPOST: (NSString *) path
                 postData: (NSData *) data
               withAccept: (NSString *) acceptValue
          withContentType: (NSString *) ctValue
{
    NSString* urlString;
    if ([path hasPrefix:@"/"]) {
        urlString = [NSString stringWithFormat:@"%@%@", serviceUrl, path];
    } else {
        urlString = [NSString stringWithFormat:@"%@/rest/%@", serviceUrl, path];

    }
    NSMutableURLRequest *request = [self prepareRequest:@"POST" requestWithUrl:urlString];

    [request setHTTPBody:data];
    if (ctValue) [request setValue:ctValue forHTTPHeaderField:contenttype];
    if (acceptValue) [request setValue:acceptValue forHTTPHeaderField:accept];
    NSData *jsonData = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
    NSError *error = nil;
    if ([acceptValue isEqualToString:textplain]) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        // return [NSString stringWithUTF8String:[jsonData bytes]];
    }
    
    // [self dumpJsonData:jsonData url:urlString];
    
    return jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : @"returnin gsth";
}

+(void) dumpJsonData: (NSData *) jsonData url: (NSString *) url {
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    DLog(@"%@", url);
    DLog(@"%@", jsonString);
}

+ (NSData *) stringToData: (NSString *) string {
    const char *utf8String = [string UTF8String];
    return [NSData dataWithBytes:utf8String length:strlen(utf8String)];
}

#pragma mark - Authentication

+ (NSString *) requestAuthToken: (NSString *) username password: (NSString *) password {
    NSData *postData = [self stringToData:[NSString stringWithFormat:@"%@\n%@", username, password]];
    
    return [[self executeARLearnPostWithAuthorization:@"login" postData:postData withContentType:textplain] objectForKey:@"auth"];
}

#pragma mark - Runs

+ (NSDictionary *) runsParticipate {
    return [self executeARLearnGetWithAuthorization:@"myRuns/participate"];
}

+ (NSDictionary *) runsParticipateFrom: (NSNumber *) from{
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"myRuns/participate?from=%lld", [from longLongValue]]];
}

+ (NSDictionary *) runsWithId: (NSNumber *) id{
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"myRuns/runId/%lld", [id longLongValue]]];
}

+ (NSDictionary *) createRun: (NSNumber *) gameId withTitle: (NSString *) runTitle {
    NSDictionary *runDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                gameId, @"gameId",
                                runTitle, @"title",
                                nil];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:runDict options:0 error:nil];
    return [self executeARLearnPostWithAuthorization:@"myRuns" postData:postData withContentType:applicationjson];
}

#pragma mark - Users

+ (NSDictionary *) createUser: (NSNumber *) runId
                 accountType: (NSNumber *) accountType
                 withLocalId:(NSString *) localId {
    
    NSDictionary *userDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                             runId, @"runId",
                             accountType, @"accountType",
                             localId, @"localId",
                             nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:nil];
    
    return [self executeARLearnPostWithAuthorization:@"users" postData:postData withContentType:applicationjson];
}

#pragma mark - Games

+ (NSDictionary *) gamesParticipate {
    return [self executeARLearnGetWithAuthorization:@"myGames/participate"];
}

+ (NSDictionary *) gamesParticipateFrom: (NSNumber *) from{
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"myGames/participate?from=%lld", [from longLongValue]]];
}

+ (NSDictionary *) game: (NSNumber *) gameId {
   return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"myGames/gameId/%lld", [gameId longLongValue]]];
}

+ (NSDictionary *) createGame: (NSString *) gameTitle {
    NSDictionary *runDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                             gameTitle, @"title",
                             nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:runDict options:0 error:nil];
    
    return [self executeARLearnPostWithAuthorization:@"myGames" postData:postData withContentType:applicationjson];
}

#pragma mark - GeneralItems

+ (NSDictionary *) itemsForRun: (int64_t) runId {
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"generalItems/runId/%lld", runId ]];
}

+ (NSDictionary *) itemsForGameFrom: (NSNumber *) gameId from:(NSNumber *) from {
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"generalItems/gameId/%lld?from=%lld", [gameId longLongValue],[from longLongValue] ]];
}

+ (NSDictionary *) itemVisibilityForRun: (NSNumber *) runId {
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"generalItemsVisibility/runId/%lld", [runId longLongValue]]];
}

+ (NSDictionary *) itemVisibilityForRun: (NSNumber *) runId from: (NSNumber *) from {
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"generalItemsVisibility/runId/%lld?from=%lld", [runId longLongValue], [from longLongValue]]];
}

+ (id) createGeneralItem:(NSString *)title description:(NSString *)description type:(NSNumber *)type gameId:(NSNumber *)gameId
{
    //Full/Return value:
    //    {
    //        "type": "org.celstec.arlearn2.beans.generalItem.NarratorItem",
    //        "gameId": 6356217932808192,
    //        "deleted": false,
    //        "lastModificationDate": 1376052351788,
    //        "id": 3713019,
    //        "sortKey": 0,
    //        "scope": "user",
    //        "name": "TEST ITEM",
    //        "description": "",
    //        "autoLaunch": false,
    //        "showCountDown": false,
    //        "section": "section1",
    //        "fileReferences": [],
    //        "richText": "",
    //        "openQuestion": {
    //            "withPicture": true,
    //            "withText": true,
    //            "withValue": true,
    //            "withAudio": true,
    //            "withVideo": true,
    //            "valueDescription": "voer temp in",
    //            "textDescription": "voer text in"
    //        },
    //        "roles": []
    //    }
    
    //Minimal ex openQuestion:
    //    {
    //        "type": "org.celstec.arlearn2.beans..generalItem.NarratorItem",
    //        "gameId": 0,
    //        "name": "Item name",
    //        "description": "Item description",
    //        "richText": "<p>Item description</p>"
    //        "openQuestion": {
    //            "withPicture": true,
    //            "withText": true,
    //            "withValue": true,
    //            "withAudio": true,
    //            "withVideo": true,
    //            "valueDescription": "voer temp in",
    //            "textDescription": "voer text in"
    //        },
    //    }
    
    NSDictionary *openQuestion = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [type isEqualToNumber:[NSNumber numberWithInt:0]]?@"true":@"false",         @"withPicture",
                                  [type isEqualToNumber:[NSNumber numberWithInt:1]]?@"true":@"false",         @"withVideo",
                                  [type isEqualToNumber:[NSNumber numberWithInt:2]]?@"true":@"false",         @"withAudio",
                                  [type isEqualToNumber:[NSNumber numberWithInt:3]]?@"true":@"false",         @"withText",
                                  [type isEqualToNumber:[NSNumber numberWithInt:4]]?@"true":@"false",         @"withValue",
                                  nil];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"org.celstec.arlearn2.beans.generalItem.NarratorItem",   @"type",
                          gameId,                                                   @"gameId",
                          title,                                                    @"name",
                          description,                                              @"description",
                          description,                                              @"richText",
                          openQuestion,                                             @"openQuestion",
                          nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    return [self executeARLearnPostWithAuthorization:@"generalItems" postData:postData withContentType:applicationjson ];
    
}

#pragma mark - Responses

+ (NSDictionary*) responsesForRun: (NSNumber *) runId {
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"response/runId/%lld", [runId longLongValue]]];
}

#pragma mark - APN

+ (void) registerDevice: (NSString *) deviceToken withUID: (NSString *) deviceUniqueIdentifier withAccount: (NSString *) account withBundleId: (NSString *) bundleIdentifier{
    if (!account) return;
    
    NSDictionary *apnRegistrationBean = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         @"org.celstec.arlearn2.beans.notification.APNDeviceDescription",   @"type",
                                         account,                                                           @"account",
                                         deviceUniqueIdentifier,                                            @"deviceUniqueIdentifier",
                                         deviceToken,                                                       @"deviceToken",
                                         bundleIdentifier,                                                  @"bundleIdentifier",
                                         nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:apnRegistrationBean options:0 error:nil];
    
    [self executeARLearnPOST:@"notifications/apn" postData:postData withAccept:nil withContentType:applicationjson ];
    
}

#pragma mark - Actions

+ (void) publishAction: (NSDictionary *) actionDict {
    NSData *postData = [NSJSONSerialization dataWithJSONObject:actionDict options:0 error:nil];
    
    [self executeARLearnPostWithAuthorization:@"actions" postData:postData withContentType:applicationjson];
}

+ (void) publishAction: (NSNumber *) runId
                    action: (NSString *) action
                    itemId: (NSNumber *) itemId
                    time: (NSNumber *) time
                  itemType:(NSString *) itemType {
    NSString *accountType = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"];
    NSString *accountLocalId = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"];
    NSString *account = [NSString stringWithFormat:@"%@:%@", accountType, accountLocalId];
    
    NSDictionary *actionDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                action,         @"action",
                                runId,          @"runId",
                                itemId,         @"generalItemId",
                                account,        @"userEmail",
                                time,           @"time",
                                itemType,       @"generalItemType",
                                nil];
    
    [self publishAction:actionDict];
}

#pragma mark - Response

+ (void) publishResponse: (NSDictionary *) responseDict {
    NSData *postData = [NSJSONSerialization dataWithJSONObject:responseDict options:0 error:nil];
    
    [self executeARLearnPostWithAuthorization:@"response" postData:postData withContentType:applicationjson];
}

+ (void) publishResponse: (NSNumber *) runId
           responseValue: (NSString *) value
                  itemId: (NSNumber*) generalItemId
               timeStamp: (NSNumber*) timeStamp{
    NSString* accountType = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"];
    NSString* accountLocalId = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"];
    NSString* account = [NSString stringWithFormat:@"%@:%@", accountType, accountLocalId];
    
    NSDictionary *responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                value,              @"responseValue",
                                runId,              @"runId",
                                generalItemId,      @"generalItemId",
                                timeStamp,          @"timestamp",
                                account,            @"userEmail",
                                nil];
    
    [self publishResponse:responseDict];
}

#pragma mark - File upload

/*!
 *  Generate the upload Url.
 *
 *  @param fileName <#fileName description#>
 *  @param runId    <#runId description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *) requestUploadUrl: (NSString *) fileName withRun:(NSNumber *) runId {
    NSString *str =[NSString stringWithFormat:@"runId=%@&account=%@:%@&fileName=%@", runId,
                    [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"],
                    [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"],fileName];
    
    id response = [self executeARLearnPOST:[NSString stringWithFormat: @"/uploadServiceWithUrl"]
                                  postData:[str dataUsingEncoding:NSUTF8StringEncoding]
                                withAccept:textplain
                           withContentType:xwwformurlencode];
    
    return (NSString *) response;
}

/*!
 *  Perform an upload of a File.
 *
 *  @param uploadUrl     <#uploadUrl description#>
 *  @param fileName      <#fileName description#>
 *  @param contentTypeIn <#contentTypeIn description#>
 *  @param data          <#data description#>
 */
+ (void) perfomUpload: (NSString *) uploadUrl withFileName:(NSString *) fileName
          contentType:(NSString *) contentTypeIn withData:(NSData *) data {
    DLog(@"Uploading %@ - %@", contentTypeIn, fileName);
    
    NSString *boundary = @"0xKhTmLbOuNdArY";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    if (data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploaded_file\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", contentTypeIn] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //        [body appendData:[[NSString stringWithString:@"Content-Type: %@\r\n\r\n", contentTypeIn] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];

    uploadUrl = [uploadUrl stringByReplacingOccurrencesOfString:@"localhost:8888" withString:@"192.168.1.8:8080"];
    [request setURL:[NSURL URLWithString: uploadUrl]];
    
    [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];

    DLog(@"Uploaded %@ - %@", contentTypeIn, fileName);
}

#pragma mark - Account

+ (NSDictionary *) anonymousLogin: (NSString *) account {
    return [self executeARLearnGet:[NSString stringWithFormat:@"account/anonymousLogin/%@", account]];
}

+ (NSDictionary *) accountDetails {
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"account/accountDetails"]];
}

#pragma mark - oauth info

+ (NSDictionary *) oauthInfo {
    return [self executeARLearnGet:@"oauth/getOauthInfo"];
}

+ (NSDictionary *) search: (NSString *) query {
    return [self executeARLearnPostWithAuthorization:@"myGames/search" postData:[self stringToData:query] withContentType:applicationjson];
}

+ (NSDictionary *) featured {
    return [self executeARLearnGetWithAuthorization:@"myGames/featured"];
}

+ (NSDictionary *) geoSearch: (NSNumber*) distance withLat:(NSNumber *) lat withLng: (NSNumber *) lng {
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"myGames/search/lat/%f/lng/%f/distance/%ld", lat.doubleValue, lng.doubleValue, distance.longValue  ]];
}

+ (NSDictionary *) defaultThread: (NSNumber *) runId {
        return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"messages/thread/runId/%@/default", runId ]];
}

+ (NSDictionary *) defaultThreadMessages: (NSNumber *) runId {
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"messages/runId/%@/default", runId ]];
}

+ (NSDictionary *) addMessage: (NSString *) message {
    return [self executeARLearnPostWithAuthorization:@"messages/message" postData:[self stringToData:message] withContentType:applicationjson];
}

+ (NSDictionary *) getUserInfo: (NSNumber *) runId userId:(NSString *) userId providerId:(NSString *) providerId {
    return [self executeARLearnGetWithAuthorization:[NSString stringWithFormat:@"users/runId/%@/account/%@:%@", runId, providerId, userId]];
}

@end
