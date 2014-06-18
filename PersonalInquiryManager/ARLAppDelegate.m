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

static NSRecursiveLock *_theLock;
static NSCondition *_theAbortLock;

static CLLocationManager *locationManager;
static CLLocationCoordinate2D currentCoordinates;

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
    NSString *gitHash = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleBuildVersion"];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSLog(@"[%s] Version String:  %@",__func__, appVersion);
    NSLog(@"[%s] Build Number:    %@",__func__, appBuild);
    NSLog(@"[%s] Git Commit Hash: %@",__func__, gitHash);
    
    // Register default preferences.
    NSDictionary *appDefault = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:NO],       DEVELOPMENT_MODE,
                                [NSNumber numberWithBool:YES],      PROXY_MODE,
                                [NSNumber numberWithInt:1],         INQUIRY_VISIBILITY,
                                [NSNumber numberWithInt:2],         INQUIRY_MEMBERSHIP,
                                gitHash,                            GIT_HASH,
                                appVersion,                         APP_VERSION,
                                nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefault];
    
    // Synchronize preferences.
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Override point for customization after application launch.
    _networkAvailable = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    [reach startNotifier];
    
    _networkAvailable = [NSNumber numberWithBool:[reach isReachable]];
    
#warning This Location code must be relocated to a better place!!
    currentCoordinates =  CLLocationCoordinate2DMake(0.0f, 0.0f);
    
    [self startStandardUpdates];
    
    // Create Database Context etc here so we get an early error if database was updated.
    if (![self managedObjectContext]) {
        [self ShowAbortMessage:NSLocalizedString(@"Notice", @"Notice")
                       message:NSLocalizedString(@"The database has been changed. Please re-install the application",@"The database has been changed. Please re-install the application")];
    }
    
    return YES;
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
}

/*!
 *  See SDK.
 *
 *  @param application <#application description#>
 */
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

/*!
 *  See SDK.
 *
 *  @param application <#application description#>
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

/*!
 *  See SDK.
 *
 *  @param application <#application description#>
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

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
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
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
        NSLog(@"[%s]\r\n*******************************************\r\nCreating a Persistent Store Coordinator\r\n*******************************************", __func__);
        
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ARLDatabase.sqlite"];
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"[%s] Unresolved error %@, %@", __func__, error, [error userInfo]);
            
            return nil;
        }
    }

    return _persistentStoreCoordinator;
}

/*!
 *  Wipe out the core data database and underlying sqlite storage.
 *
 *  NOTE: Core Data does not like this method, so we use deleteAllOfEntity instead.
 */
- (void)clearDatabase {
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
    
    [context save:&error];
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
    
    NSError *error = nil;
    NSArray *unsyncedData = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"error %@", error);
    }
    
    return unsyncedData;
}

/*!
 *  Synchronize data at first run (after login) or manually with the Sync button.
 */
- (void) syncData {
    if (ARLNetwork.networkAvailable==YES) {
        NSLog(@"[%s] %s",__func__, "Syncing Data\r\n*******************************************");

        // syncActions is also triggered by syncResponses!
        // [ARLCloudSynchronizer syncActions:self.managedObjectContext];
        [ARLCloudSynchronizer syncGamesAndRuns:self.managedObjectContext];
        [ARLCloudSynchronizer syncResponses:self.managedObjectContext];
        
        [INQCloudSynchronizer syncInquiries:self.managedObjectContext];
        [INQCloudSynchronizer syncUsers:self.managedObjectContext];
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
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
           [ARLNetwork ShowAbortMessage:error func:[NSString stringWithFormat:@"%s",__func__]];
        }
    }
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
    [ARLAccountDelegator deleteCurrentAccount:self.managedObjectContext];
    
    _CurrentAccount = nil;
}

/*!
 *  Getter for isLoggedIn property.
 *
 *  @return If TRUE the user is logged-in.
 */
- (NSNumber *)networkAvailable {
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
    
//    NSLog(@"Reachability Changed");
//    NSLog(@"From: %@", _networkAvailable);
    
    _networkAvailable = [NSNumber numberWithBool:[reach isReachable]];

//    NSLog(@"To: %@", _networkAvailable);
//    
//    NSLog(@" All:  %d", [reach isReachable]);
//    NSLog(@" Wifi: %d", [reach isReachableViaWiFi]);
//    NSLog(@" WWan: %d", [reach isReachableViaWWAN]);
}

/*!
 *  Convert NSDictionary to a JSON NSString.
 *
 *  @param jsonDictionary The NSDictionary to convert.
 *
 *  @return The resulting JSON NSString.
 */
+ (NSString *) jsonString:(NSDictionary *) jsonDictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:0
                                                         error:&error];
    
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
            NSLog(@"latitude %+.6f, longitude %+.6f\n",
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
