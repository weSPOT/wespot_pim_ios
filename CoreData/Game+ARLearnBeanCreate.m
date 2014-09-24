//
//  Game+ARLearnBeanCreate.m
//  ARLearn
//
//  Created by Stefaan Ternier on 2/3/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "Game+ARLearnBeanCreate.h"

@implementation Game (ARLearnBeanCreate)

/*!
 *  Retrieve a Game.
 *
 *  @param gameId  The GameId
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested Game.
 */
+ (Game *) retrieveGame: (NSNumber *) gameId inManagedObjectContext: (NSManagedObjectContext *) context {
    Game *game = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
    request.predicate = [NSPredicate predicateWithFormat:@"gameId = %lld", [gameId longLongValue]];    
    NSError *error = nil;
    NSArray *games = [context executeFetchRequest:request error:&error];
    
    if (!games || [games count] > 0) {
        game = [games lastObject];
    }
    
    return game;
}

/*!
 *  Retrieve or Create a Game given a NSDictionary
 *
 *  @param gameDict Should at least contain gameId, title, owner, creator, config, mapAvailable and description.
 *  @param context  Tjhe NSManagedObjectContext.
 *
 *  @return The requested or newly created Game.
 */
+ (Game *) gameWithDictionary: (NSDictionary *) gameDict inManagedObjectContext: (NSManagedObjectContext *) context {
    Game *game = [self retrieveGame:[gameDict objectForKey:@"gameId"] inManagedObjectContext:context];

    if (!game) {
        game = [NSEntityDescription insertNewObjectForEntityForName:@"Game"
                                             inManagedObjectContext:context];
    }
    game.title = [gameDict objectForKey:@"title"];
    game.owner = [gameDict objectForKey:@"owner"];
    game.creator = [gameDict objectForKey:@"creator"];
    game.gameId = [gameDict objectForKey:@"gameId"];
    game.hasMap = [[gameDict objectForKey:@"config"] objectForKey:@"mapAvailable"];
    
    // DLog(@"Exists %@", [gameDict objectForKey:@"description"]);
    
    if ([gameDict objectForKey:@"description"]) {
        game.richTextDescription = [gameDict objectForKey:@"description"];
    }
    
    if (!game.hasMap) {
        game.hasMap = NO;
    }
    
    [self setCorrespondingRuns:game];
    
    [INQLog SaveNLog:context];
    
    return game;
}

/*!
 *  Set the Set of Runs that belong to a Game.
 *
 *  @param game The Game to update.
 */
+ (void) setCorrespondingRuns: (Game *) game {
    NSManagedObjectContext * context = game.managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Run"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"gameId == %lld", [game.gameId longLongValue]];
    
    NSError *error = nil;
    NSArray *runs = [context executeFetchRequest:request error:&error];
    for (Run *run in runs) {
        [game addCorrespondingRunsObject:run];
    }
}

@end
