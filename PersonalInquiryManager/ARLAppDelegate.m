//
//  ARLAppDelegate.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 6/13/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLAppDelegate.h"

@interface ARLAppDelegate (private)

-(void)reachabilityChanged:(NSNotification*)note;

@end

@implementation ARLAppDelegate

// veg: These three need to stay as we implement the getter (so NO default _ prefixed backing field).
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize isLoggedIn = _isLoggedIn;
@synthesize networkAvailable = _networkAvailable;

@synthesize CurrentAccount = _CurrentAccount;

@synthesize modelVersion = _modelVersion;

static NSRecursiveLock *_theLock;
static NSCondition *_theAbortLock;

static CLLocationManager *locationManager;
static CLLocationCoordinate2D currentCoordinates;

static BOOL _syncAllowed = NO;

/*!
 *  A Recursive Lock used to serialize the syncs.
 *  Maybe not nessesary anymore if all syncs share a 
 *  common context (which is not the case yet).
 *
 *  @return The Recusive Lock.
 */
+ (NSRecursiveLock *) theLock {
    if(!_theLock){
        _theLock = [[NSRecursiveLock alloc] init];
        //[_theLock setName:@"Recursive Sync Lock"];
    }
    return _theLock;
}

+ (NSCondition *) theAbortLock {
    if(!_theAbortLock){
        _theAbortLock = [[NSCondition alloc] init];
        //[_theAbortLock setName:@"Show Abort Condition"];
    }
    return _theAbortLock;
}

+ (BOOL) SyncAllowed {
    return _syncAllowed;
}

+ (void) setSyncAllowed:(BOOL) value {
    _syncAllowed = value;
}

/*!
 *  See SDK.
 *
 *  Called when the app has been fully loaded.
 *
 *  @param application   <#application description#>
 *  @param launchOptions <#launchOptions description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    _networkAvailable = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability *reach = [Reachability reachabilityWithHostname:serviceUrl];

    [reach startNotifier];

    //WARNING: Let the Reachabilty Notifier run for half a second, so we have more chance to performing the initial sync!
    NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
    [myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    //WARNING: Warning This Location code must be relocated to a better place!!
    currentCoordinates =  CLLocationCoordinate2DMake(0.0f, 0.0f);
    
    [self startStandardUpdates];
    
    // Create Database Context etc here so we get an early error if database was updated.
    if (![self managedObjectContext]) {
        [self ShowAbortMessage:NSLocalizedString(@"Notice", @"Notice")
                       message:NSLocalizedString(@"The database has been changed. Please re-install the application",@"The database has been changed. Please re-install the application")];
    } else {
        // DLog(@"Updating ResponseType Start");
        
        // Correct Responses.
        
        NSPredicate *unknownTypes = [NSPredicate predicateWithFormat:@"(responseType = %@)",[NSNumber numberWithInt:UNKNOWN]];
        
        for (Response *response in [ARLAppDelegate retrievAllOfEntity:self.managedObjectContext enityName:@"Response" predicate:unknownTypes]) {
            if ([response.responseType isEqualToNumber:[NSNumber numberWithInt:UNKNOWN]]) {
                
                if ([response.contentType isEqualToString:@"audio/aac"]) {
                    response.responseType = [NSNumber numberWithInt:AUDIO];
                } else if ([response.contentType isEqualToString:@"audio/mp3"]) {
                    response.responseType = [NSNumber numberWithInt:AUDIO];
                } else if ([response.contentType isEqualToString:@"audio/amr"]) {
                    response.responseType = [NSNumber numberWithInt:AUDIO];
                } else if ([response.contentType isEqualToString:@"application/jpg"]) {
                    response.responseType = [NSNumber numberWithInt:PHOTO];
                } else if ([response.contentType isEqualToString:@"video/quicktime"]) {
                    response.responseType = [NSNumber numberWithInt:VIDEO];
                } else if (response.value) {
                    NSError *error = nil;
                    NSData *JSONdata = [response.value dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONdata
                                                                               options: NSJSONReadingMutableContainers
                                                                                 error:&error];
                    if ([dictionary valueForKey:@"text"]) {
                        response.responseType = [NSNumber numberWithInt:TEXT];
                    } else if ([dictionary valueForKey:@"value"]) {
                        response.responseType = [NSNumber numberWithInt:NUMBER];
                    } else {
                        // response.responseType = [NSNumber numberWithInt:UNKNOWN];
                    }
                    
                } else {
                    // response.responseType = [NSNumber numberWithInt:UNKNOWN];
                }
            }
        }
        
        [INQLog SaveNLog:self.managedObjectContext];
        
        // DLog(@"Updating ResponseType Finish");
    }

    _networkAvailable = [NSNumber numberWithBool:[self connected] && [self serverok]];

    // Get preferences Data.
    NSString *gitHash =      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleBuildVersion"];
    NSString *appVersion =   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _modelVersion = [NSString stringWithString:[[[self managedObjectModel].versionIdentifiers allObjects] objectAtIndex:0]];
    
    // NSString *appBuild =    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    Log(@"Version String:  %@", appVersion);
    // Log(@"Build Number:    %@", appBuild);
    Log(@"Git Commit Hash: %@", gitHash);
    Log(@"Model Version: %@",   self.modelVersion);
    
    // Log(@"deviceUniqueIdentifier: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceUniqueIdentifier"]);
    // Log(@"deviceToken:            %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]);
    // Log(@"bundleIdentifier:       %@", [[NSBundle mainBundle] bundleIdentifier]);
    
    // Register default preferences.
    NSDictionary *appDefault = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:NO],       DEVELOPMENT_MODE,
                                [NSNumber numberWithBool:YES],      PROXY_MODE,
                                [NSNumber numberWithBool:NO],       ENABLE_LOGGING,
                                
                                [NSNumber numberWithInt:1],         INQUIRY_VISIBILITY,
                                [NSNumber numberWithInt:2],         INQUIRY_MEMBERSHIP,
                                
                                gitHash,                            GIT_HASH,
                                self.modelVersion,                  MODEL_VERSION,
                                appVersion,                         APP_VERSION,
                                nil];
    
    //#warning FORCING LOGGING.
    //    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:TRUE] forKey:ENABLE_LOGGING];
    
    // ERROR LOGGIN TEST CODE
    {
        // DLog(@"Test: %@", @"Clog");
    }
    
    {
        // DLog(@"Test: %@", @"Dlog");
    }
    
    {
        // NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
        //                       @"Test: ELog", NSLocalizedDescriptionKey,
        //                       nil];
        // NSError *error = [[NSError alloc] initWithDomain:@"DOMAIN" code:15 userInfo:dict];
        // ELog(error);
    }
    
    {
        // NSError *error = nil;
        // ELog(error);
    }
    
    {
        // EELog();
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefault];

    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif)
    {
        NSLog(@"Accept push Notification when app is not open if stat ");
        // [self processRemoteNotificationApplicationStateActive:remoteNotif];
    }
    
    // Synchronize preferences.
    [[NSUserDefaults standardUserDefaults] synchronize];

    return YES;
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return !(networkStatus == NotReachable);
}

- (BOOL)serverok
{
    Reachability *reachability = [Reachability reachabilityWithHostname:serviceUrl];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return !(networkStatus == NotReachable);
}

- (void) ShowAbortMessage: (NSString *) title message:(NSString *) message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                          otherButtonTitles:nil, nil];
    
   // UIAlertView should run on the main thread!
   [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

/*!
 *  Handle the Dismiss Button by unlocking theAbortLock.
 *
 *  @param alertView   <#alertView description#>
 *  @param buttonIndex <#buttonIndex description#>
 */
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [ARLAppDelegate.theAbortLock signal];
}

/*!
 *  See SDK.
 *
 *  @param application ;;
 */
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // Log(@"%@", @"applicationWillResignActive");
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [INQLog SaveNLog:appDelegate.managedObjectContext];
}

/*!
 *  See SDK.
 *
 *  @param application <#application description#>
 */
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // 2) PRESSING HOME.
    
    // Log(@"%@", @"applicationDidEnterBackground");
}

/*!
 *  See SDK.
 *
 *  @param application <#application description#>
 */
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // 3) REACTIVATIONS #1.
    _networkAvailable = [NSNumber numberWithBool:[self connected] && [self serverok]];
    
    if (![_networkAvailable isEqualToNumber:[NSNumber numberWithInt:0]]) {
        // Upload any stuff still pending.
        if (self.managedObjectContext) {
            [ARLCloudSynchronizer syncResponses:self.managedObjectContext];
        }
    }
}

/*!
 *  See SDK.
 *
 *  @param application
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    // 1) AFTER STARTUP.
    // 4) REACTIVATIONS #2.

    // Log(@"%@", @"applicationDidBecomeActive");
}

/*!
 *  See SDK.
 *
 *  @param application <#application description#>
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    // Log(@"%@", @"applicationWillTerminate");
}

#pragma mark - APN

// #warning APN CODE AHEAD

//http://ar-learn.appspot.com/network.html?path=notifications/test/deviceToken/d8f810ad024f84c1070814614a71e2568a3803aff8c3b514a371c90c5273d274/apns/pim.p12
//notifications/test/deviceToken/d8f810ad024f84c1070814614a71e2568a3803aff8c3b514a371c90c5273d274/apns/arlearn.p12
//notifications/test/deviceToken/d8f810ad024f84c1070814614a71e2568a3803aff8c3b514a371c90c5273d274/apns/pim.p12/prod

/*!
 * Register for APN with Apple.
 *
 *  @param application <#application description#>
 */
- (void)doRegisterForAPN:(UIApplication *)application
{
    // #warning APN REGISTRATION CODE DISABLED FOR NOW.
    
    // See http://stackoverflow.com/questions/24216632/remote-notification-ios-8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {    UIUserNotificationSettings *settings =
#ifdef __IPHONE_8_0
        //Right, that is the point
        [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge |
                                                      UIRemoteNotificationTypeSound |
                                                      UIRemoteNotificationTypeAlert)
                                          categories:nil];
        [application registerUserNotificationSettings:settings];
#endif
    } else {
        //register to receive notifications
        UIRemoteNotificationType myTypes =
        UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        
        [application registerForRemoteNotificationTypes:myTypes];
    }
}


//TESTCODE: Remote notifications
/*!
 *  Called when receiving a Remote Notification.
 *         
 *  @param app   <#app description#>
 *  @param notif <#notif description#>
 */
//- (void)application:(UIApplication *)app didReceiveRemoteNotification:(UILocalNotification *)notif {
//    //TODO: Implement
//    Log(@"didReceiveRemoteNotification: %@", notif.userInfo);
//    
//    //    NSString *itemName = [notif.userInfo objectForKey:ToDoItemKey];
//    //    [viewController displayItem:itemName];  // custom method
//    //    app.applicationIconBadgeNumber = notification.applicationIconBadgeNumber - 1;
//}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    Log(@"didReceiveRemoteNotification: %@", userInfo);
}

/*!
 *  Registration Success.
 *
 *  @param application The application
 *  @param deviceToken The Device Token
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* newToken = [deviceToken description];
    
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Store DeviceToken
    [[NSUserDefaults standardUserDefaults] setObject:newToken
                                              forKey:@"deviceToken"];
    
    //!!!: This UID behaves very different on iOS 1-6 and iOS 7.
    UIDevice *device = [UIDevice currentDevice];
    
    [[NSUserDefaults standardUserDefaults] setObject:[device.identifierForVendor UUIDString]
                                              forKey:@"deviceUniqueIdentifier"];

    Log(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]);
    Log(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceUniqueIdentifier"]);
    
    if ([ARLNetwork RegisteredForAPN] != YES &&
          [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"] &&
          [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"]) {
        NSString *localId  = [NSString stringWithFormat:@"%@:%@",
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"],
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"]];
        [ARLNetwork registerAccount:localId];
    }

    Log(@"RegisteredForAPN: %@:", [NSNumber numberWithBool:[ARLNetwork RegisteredForAPN]]);
}

#ifdef __IPHONE_8_0
/*!
 *  See http://stackoverflow.com/questions/24485681/registerforremotenotifications-method-not-being-called-properly
 *
 *  @param application          <#application description#>
 *  @param notificationSettings <#notificationSettings description#>
 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    Log(@"didRegisterUserNotificationSettings");
    
    // Register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    //    if ([identifier isEqualToString:@"declineAction"]){
    //    }
    //    else if ([identifier isEqualToString:@"answerAction"]){
    //    }
}

#endif

/*!
 *  Registration Failure (for instance when running in the emulator);
 *
 *  @param application The application
 *  @param error       The error
 */
- (void)Implement:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //TODO: Implement
    Log(@"didFailToRegisterForRemoteNotificationsWithError: %@", error.description);
    
    [[NSUserDefaults standardUserDefaults] setObject:FALSE
                                              forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] setObject:FALSE
                                              forKey:@"deviceUniqueIdentifier"];
}

#pragma mark - CoreData

/*!
 *  If the context doesn't already exist, it is created from the application's Store Coordinator.
 *
 *  @return Returns the managed object context for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            //See http://www.cocoanetics.com/2012/07/multi-context-coredata/
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_mocDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    
    return _managedObjectContext;
}

/*!
 *  If the model doesn't already exist, it is created from the application's model.
 *
 *  @return Returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ARLDatabase" withExtension:@"momd"];
    
        Log(@"Model Location: %@", modelURL);
        
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

        //_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil] ;
        
        Log(@"Model Version: %@", [[_managedObjectModel.versionIdentifiers allObjects] objectAtIndex:0]);
    }
 
    return _managedObjectModel;
}

/*!
 *  If the coordinator doesn't already exist, it is created and the application's store added to it.
 *
 *  @return Returns the persistent store coordinator for the application.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        // DLog(@"\r\n*******************************************\r\nCreating a Persistent Store Coordinator\r\n*******************************************");
        
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ARLDatabase.sqlite"];
        
        Log(@"Database Location: %@", storeURL);
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        
        // See http://stackoverflow.com/questions/22268854/updating-core-data-with-existing-sqlite-db
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
        options[NSInferMappingModelAutomaticallyOption] = @YES;
        options[NSSQLitePragmasOption] = @{ @"journal_mode":@"DELETE" };
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:storeURL
                                                             options:options
                                                               error:&error]) {
            
            ELog(error);

            return nil;
        }
        
        Log(@"Model Version: %@", [[[self managedObjectModel].versionIdentifiers allObjects] objectAtIndex:0]);
    }

    return _persistentStoreCoordinator;
}

/*!
 *  Wipe out the core data database and underlying sqlite storage.
 *
 *  NOTE: Core Data does not like this method, so we use deleteAllOfEntity instead.
 */
- (void) clearDatabase {
//    NSPersistentStore *store = [self.persistentStoreCoordinator.persistentStores lastObject];
//    NSError *error = nil;
//    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ARLDatabase.sqlite"];
//    
//    [self.persistentStoreCoordinator removePersistentStore:store error:&error];
//    
//    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
//    
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        [ARLNetwork ShowAbortMessage:error func:[NSString stringWithFormat:@"%s",__func__]];
//    }
}

/*!
 *  Deleted all records of a specified Entity.
 *
 *  @param context The NSManagedObjectContext.
 *  @param name    The Name of the Entity.
 */
+ (void) deleteAllOfEntity: (NSManagedObjectContext *) context enityName:(NSString *) name {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
    
    NSError *error = nil;
    NSArray *entities = [context executeFetchRequest:request error:&error];
    if (error) {
        [ARLNetwork ShowAbortMessage:error func:[NSString stringWithFormat:@"%s",__func__]];
    }
    
    for (id entity in entities) {
        [context deleteObject:entity];
    }
    
    [INQLog SaveNLog:context];
}

/*!
 *  Get all records of a specified Entity.
 *
 *  @param context The NSManagedObjectContext.
 *  @param name    The Name of the Entity.
 *
 *  @return An Array with all GeneralItems.
 */
+ (NSArray *) retrievAllOfEntity: (NSManagedObjectContext *) context enityName:(NSString *) name {
    return [ARLAppDelegate retrievAllOfEntity:context enityName:name predicate:nil];
}

/*!
 *  Get all records of a specified Entity.
 *
 *  @param context The NSManagedObjectContext.
 *  @param name    The Name of the Entity.
 *
 *  @return An Array with all GeneralItems.
 */
+ (NSArray *) retrievAllOfEntity: (NSManagedObjectContext *) context enityName:(NSString *) name predicate:(NSPredicate *) predicate {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
    
    request.predicate = predicate;
    request.fetchBatchSize = 8;
    
    NSError *error = nil;
    NSArray *unsyncedData = [context executeFetchRequest:request error:&error];
    ELog(error);
    
    return unsyncedData;
}

/*!
 *  Synchronize data at first run (after login) or manually with the Sync button.
 */
- (void) syncData {
    if (ARLNetwork.networkAvailable) {
        // DLog(@"%s", "Syncing Data\r\n*******************************************");

        // syncActions is also triggered by syncResponses!
        [ARLCloudSynchronizer syncGamesAndRuns:self.managedObjectContext];
        [ARLCloudSynchronizer syncResponses:self.managedObjectContext];
        
        [INQCloudSynchronizer syncInquiries:self.managedObjectContext];
        [INQCloudSynchronizer syncUsers:self.managedObjectContext];
        
        [ARLFileCloudSynchronizer syncGeneralItems:self.managedObjectContext];
    }
}

/*!
 *  On a save notification, merge the conext into the main one.
 *
 *  @param notification <#notification description#>
 */
- (void) _mocDidSaveNotification:(NSNotification *)notification
{
    NSManagedObjectContext *savedContext = [notification object];
    if (_managedObjectContext == savedContext) {
        return;
    }
    
    if (_managedObjectContext.persistentStoreCoordinator != savedContext.persistentStoreCoordinator){
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}

/*!
 *  Save NSManagedObjectContext.
 */
- (void) saveContext {
    [INQLog SaveNLogAbort:self.managedObjectContext func:[NSString stringWithFormat:@"%s",__func__]];
}

/*!
 *  Returns the Applications Document Directory.
 *
 *  @return Returns a path into the Applications Document Directory.
 */
- (NSURL *) applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/*!
 *  Getter for isLoggedIn property.
 *
 *  @return If TRUE the user is logged-in.
 */
- (NSNumber *) isLoggedIn {
    return _isLoggedIn;
}

/*!
 *  Getter for CurrentAccount.
 *
 *  Note: we need to cache the account because retrieving it 
 *        in a different context or in the main ui thread might cause deadlock.
 *  Note: because IsLoggedIn is also a rad-only property we need to update the
 *        backing field.
 *  @return The Current Account.
 */
- (Account *) CurrentAccount {
    if (!_CurrentAccount) {
        _CurrentAccount  = [Account retrieveFromDbWithLocalId:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"]
                                                  accountType:[[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]
                                           withManagedContext:self.managedObjectContext];
    }
    _isLoggedIn = [NSNumber numberWithBool:(_CurrentAccount)?YES:NO];
    
    return _CurrentAccount;
}

/*!
 *  Because CurrentAccount is a read-only property 
 *  we need to reset the backing field when doing a logout.
 */
- (void) LogOut {
    ARLAppDelegate.SyncAllowed = NO;
    
    [ARLAccountDelegator deleteCurrentAccount:self.managedObjectContext];
    
    [ARLNetwork setRegisteredForAPN:NO];
    
    _CurrentAccount = nil;
}

/*!
 *  Getter for isLoggedIn property.
 *
 *  @return If TRUE the user is logged-in.
 */
- (NSNumber *)networkAvailable {
    // Log(@"networkAvailable: %@", _networkAvailable);
    
    return _networkAvailable;
}

/*!
 *  Notification Handler for Reachability.
 *  Sets the networkAvailable property.
 *
 *  @param note The Reachability object.
 */
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability *reach = [note object];
    
    //WARNING: DEBUG LOGGING.
    
    DLog(@"Reachability Changed");
    DLog(@"From: %@", _networkAvailable);
    
    _networkAvailable = [NSNumber numberWithBool:[reach isReachable]];
    
    DLog(@"To: %@", _networkAvailable);
    
    DLog(@" All:  %d", [reach isReachable]);
    DLog(@" Wifi: %d", [reach isReachableViaWiFi]);
    DLog(@" WWan: %d", [reach isReachableViaWWAN]);
}

/*!
 *  Convert NSDictionary to a JSON NSString.
 *
 *  @param jsonDictionary The NSDictionary to convert.
 *
 *  @return The resulting JSON NSString.
 */
+ (NSString *) jsonString:(NSDictionary *) jsonDictionary {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:0
                                                         error:&error];
    ELog(error);
    
    return [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
}

/*!
 *  Retrieve the number of records from a specified table with an (filtering) predicate.
 *
 *  @param entityName <#entityName description#>
 *  @param predicate  <#predicate description#>
 *
 *  @return <#return value description#>
 */
- (NSInteger *) entityCount:(NSString *) entityName predicate:(NSPredicate *) predicate {
    
    NSFetchRequest *request = [[NSFetchRequest alloc]  init];
    
    [request setEntity:[NSEntityDescription  entityForName:entityName inManagedObjectContext:self.managedObjectContext]];
    [request setIncludesSubentities:NO];

    request.predicate = predicate;

    NSError * error = nil;
    NSInteger count =[self.managedObjectContext countForFetchRequest:request error:&error];
    
    return count;
}

/*!
 *  Retrieve the number of records from a specified table.
 *
 *  See http://stackoverflow.com/questions/1134289/cocoa-core-data-efficient-way-to-count-entities
 */
- (NSInteger *) entityCount:(NSString *) entityName {
    return [self entityCount:entityName predicate:nil];
}

/*!
 *  Use GPS to upate location.
 *
 *  See https://developer.apple.com/library/mac/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html
 */
- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    if (locationManager && CLLocationManager.locationServicesEnabled) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        // Set a movement threshold for new events.ß
        locationManager.distanceFilter = 500; // meters
        
        locationManager.pausesLocationUpdatesAutomatically=YES;
        
        [locationManager startUpdatingLocation];
    }
}

/*!
 *  Use WiFi to update location.
 */
- (void)startSignificantChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    if (locationManager && CLLocationManager.locationServicesEnabled) {
        
        locationManager.delegate = self;
        
        [locationManager startMonitoringSignificantLocationChanges];
    }
}

/*!
 *  Delegate method from the CLLocationManagerDelegate protocol.
 *
 *  @param manager   The CLLocationManager
 *  @param locations The locations to process.
 */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation *location = [locations lastObject];
    
    if (location) {
        NSDate *eventDate = location.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (abs(howRecent) < 15.0) {
            // If the event is recent, do something with it.
            DLog(@"Lat: %+.6f, Long: %+.6f\n",
                  location.coordinate.latitude,
                  location.coordinate.longitude);
        }
        
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            currentCoordinates = location.coordinate;
        }
    }
}

/*!
 *  Returns the Current Location.
 *
 *  @return the current location.
 */
+ (CLLocationCoordinate2D) CurrentLocation {
    return currentCoordinates;
}

@end
