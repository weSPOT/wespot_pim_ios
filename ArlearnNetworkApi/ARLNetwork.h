//
//  ARLNetwork.h
//  ARLearn
//
//  Created by Stefaan Ternier on 1/25/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PrivateData.h"

// Note: PrivateData.h contains a defined with the openbadges
//       Authorization key (as a String so just one define like:
//
//          #define badges_authorization_key @"<key>"
//
// Note: PrivateData.h is part of .gitignore preventing accidental checkin!
//

//#define serviceUrl    @"http://ar-learn.appspot.com"
//#define serviceUrl    @"http://192.168.1.8:8080"

#define serviceUrl      @"http://streetlearn.appspot.com"
#define openbadgesUrl   @"https://openbadgesapi.appspot.com"

#define accept          @"Accept"
#define contenttype     @"Content-Type"

#define textplain       @"text/plain"
#define applicationjson @"application/json"
#define textplain       @"text/plain"
#define xwwformurlencode @"application/x-www-form-urlencoded"

#define GET             @"GET"
#define POST            @"POST"

//#define myRunsPostfix @"myRuns"

@interface ARLNetwork : NSObject

+ (NSString *) requestAuthToken: (NSString *) username password: (NSString *) password;

//Runs
+ (NSDictionary *) runsParticipate ;
+ (NSDictionary *) runsParticipateFrom: (NSNumber *) from;
+ (NSDictionary *) runsWithId: (NSNumber *) runId;
+ (NSDictionary *) createRun: (NSNumber *) gameId withTitle: (NSString *) runTitle;

//Users
+ (NSDictionary *) createUser: (NSNumber *) runId
                   accountType: (NSNumber *) accountType
                 withLocalId:(NSString *) localId;

//Games
+ (NSDictionary *) gamesParticipate;
+ (NSDictionary *) gamesParticipateFrom: (NSNumber *) from;
+ (NSDictionary *) game: (NSNumber *) gameId;
+ (NSDictionary *) createGame: (NSString *) gameTitle;

//Runs
+ (NSDictionary *) itemsForRun: (int64_t) runId;
+ (NSDictionary *) itemsForGameFrom: (NSNumber *) gameId from:(NSNumber *) from;

//Responses
+ (NSDictionary *) responsesForRun: (NSNumber *) runId;

//GeneralItems
+ (id) createGeneralItem:(NSString *)title description:(NSString *)description type:(NSNumber *)type gameId:(NSNumber *)gameId;

//ItemVisibility
+ (NSDictionary *) itemVisibilityForRun: (NSNumber *) runId;
+ (NSDictionary *) itemVisibilityForRun: (NSNumber *) runId from: (NSNumber *) from ;

+ (void) registerDevice: (NSString *) deviceToken withUID: (NSString *) deviceUniqueIdentifier withAccount: (NSString *) account withBundleId: (NSString *) bundleIdentifier;

//Actions
+ (void) publishAction: (NSDictionary *) actionDict;
+ (void) publishAction: (NSNumber *) runId action: (NSString *) action itemId: (NSNumber *) itemId time: (NSNumber *) time itemType:(NSString *) itemType;

+ (void) publishResponse: (NSDictionary *) actionDict;
+ (void) publishResponse: (NSNumber *) runId responseValue: (NSString *) value itemId: (NSNumber *) generalItemId timeStamp: (NSNumber *) timeStamp;

//Upload
+ (NSString *) requestUploadUrl: (NSString *) fileName withRun:(NSNumber *) runId;
+ (void) perfomUpload: (NSString *) uploadUrl withFileName:(NSString *) fileName contentType:(NSString *) contentType withData:(NSData *) data;

//Accounts Helpers
+ (NSDictionary *) anonymousLogin: (NSString *) account;
+ (NSDictionary *) accountDetails;

+ (NSDictionary *) oauthInfo;

+ (NSDictionary *) search: (NSString *) query;
+ (NSDictionary *) featured;
+ (NSDictionary *) geoSearch: (NSNumber *) distance withLat:(NSNumber *) lat withLng: (NSNumber *) lng;
+ (NSDictionary *) defaultThread: (NSNumber *) runId;
+ (NSDictionary *) defaultThreadMessages: (NSNumber *) runId;
+ (NSDictionary *) defaultThreadMessages: (NSNumber *) runId from: (NSNumber *) from;
+ (NSDictionary *) addMessage: (NSString *) message;

+ (id) executeARLearnGetWithAuthorization: (NSString *) path;

+ (NSDictionary *) getUserInfo: (NSNumber *) runId userId:(NSString *) userId providerId:(NSString *) providerId;

//OpenBadges Api
+ (NSDictionary *) getUserBadges: (NSString *) userId;

@end


