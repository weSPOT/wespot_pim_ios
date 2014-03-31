//
//  Action+Create.h
//  ARLearn
//
//  Created by Stefaan Ternier on 7/23/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "Action.h"
#import "GeneralItem.h"
#import "Run.h"

@interface Action (Create)

+ (Action *) initAction: (NSString *) actionString
                forRun :(Run *) run
         forGeneralItem:(GeneralItem *) gi
 inManagedObjectContext: (NSManagedObjectContext *) context;

+ (NSArray *) getUnsyncedActions: (NSManagedObjectContext *) context;

+ (BOOL) checkAction:(NSString *) action
              forRun: (Run *) run
      forGeneralItem: (GeneralItem *) gi
inManagedObjectContext:(NSManagedObjectContext*) context;
@end
