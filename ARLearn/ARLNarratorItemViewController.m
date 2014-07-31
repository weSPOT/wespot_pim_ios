//
//  ARLNarratorItemViewController.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/18/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLNarratorItemViewController.h"

@interface ARLNarratorItemViewController ()

/*!
 *  ID's and order of the cells sections.
 */
typedef NS_ENUM(NSInteger, responses) {
    /*!
     * Uploaded Responses.
     */
    RESPONSES = 0,
    /*!
     *  Number of Responses
     */
    numResponses
};

@property (nonatomic, readwrite) BOOL withAudio;
@property (nonatomic, readwrite) BOOL withPicture;
@property (nonatomic, readwrite) BOOL withText;
@property (nonatomic, readwrite) BOOL withValue;
@property (nonatomic, readwrite) BOOL withVideo;
@property (nonatomic, readwrite) BOOL isVisible;

@property (strong, nonatomic) UITextField *valueTextField;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (strong, nonatomic) NSString *textDescription;
@property (strong, nonatomic) NSString *valueDescription;

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (readonly, nonatomic) CGFloat noColumns;
@property (readonly, nonatomic) CGFloat columnInset;

@end

@implementation ARLNarratorItemViewController

@synthesize run = _run;
@synthesize generalItem = _generalItem;
@synthesize account = _account;

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"imageItemCell";
}

/*!
 *  Getter
 *
 *  @return The Number of Columns.
 */
-(CGFloat) noColumns {
    return  4.0f;
}

/*!
 *  Getter
 *
 *  @return The Column Inset.
 */
-(CGFloat) columnInset {
    return  10.0f;
}

/*!
 *  Create a UIBarButton with a background image depending on the enabled state.
 *
 *  See http://stackoverflow.com/questions/7101608/setting-image-for-uibarbuttonitem-image-stretched
 *
 *  @param imageString The name of the Image.
 *  @param enabled     If YES the button is enabled else disabled (and having a grayed image).
 *  @param selector    The selector to use when the button is tapped.
 *
 *  @return The created UIBarButtonItem.
 */
- (UIBarButtonItem *)addUIBarButtonWithImage:(NSString *)imageString enabled:(BOOL)enabled action:(SEL)selector {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    if (enabled) {
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    // button.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImage * image = [UIImage imageNamed:imageString];
    if (!enabled) {
        image = [self grayishImage:image];
    }
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setEnabled:enabled];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

/*!
 *  Transform the image in grayscale, while keeping its transparency.
 *
 *  See http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
 *
 *  @param inputImage The Image to be grayed.
 *
 *  @return The GrayScale Image.
 */
- (UIImage *)grayishImage:(UIImage *)inputImage {
    UIGraphicsBeginImageContextWithOptions(inputImage.size, NO, inputImage.scale);
    
    @autoreleasepool {
        CGRect imageRect = CGRectMake(0.0f, 0.0f, inputImage.size.width, inputImage.size.height);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        // Draw a white background
        CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
        CGContextFillRect(ctx, imageRect);
        
        // Draw the luminosity on top of the white background to get grayscale
        [inputImage drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0f];
        
        // Apply the source image's alpha
        [inputImage drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        
    }
    
    UIImage* grayscaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return grayscaleImage;
}

/*!
 *  Process the JSON (the openQuestion object) that is stored with the GeneralItem.
 *
 *  @param jsonDict The openQuestion object in JSON format.
 */
- (void) processJsonSetup:(NSDictionary *) jsonDict {
    self.isVisible = YES;
    
    self.withAudio =   [(NSNumber*)[jsonDict objectForKey:@"withAudio"] intValue] ==1;
    self.withPicture = [(NSNumber*)[jsonDict objectForKey:@"withPicture"] intValue] ==1;
    self.withText =    [(NSNumber*)[jsonDict objectForKey:@"withText"] intValue] ==1;
    self.withValue =   [(NSNumber*)[jsonDict objectForKey:@"withValue"] intValue] ==1;
    self.withVideo =   [(NSNumber*)[jsonDict objectForKey:@"withVideo"] intValue] ==1;
    
    self.textDescription =  [jsonDict objectForKey:@"textDescription"];
    self.valueDescription = [jsonDict objectForKey:@"valueDescription"];
    
    UIBarButtonItem *audioButton = [self addUIBarButtonWithImage:@"task-record"  enabled:self.withAudio   action:@selector(collectAudio)];
    UIBarButtonItem *imageButton = [self addUIBarButtonWithImage:@"task-photo"   enabled:self.withPicture action:@selector(collectImage)];
    UIBarButtonItem *videoButton = [self addUIBarButtonWithImage:@"task-video"   enabled:self.withVideo   action:@selector(collectVideo)];
    UIBarButtonItem *noteButton  = [self addUIBarButtonWithImage:@"task-explore" enabled:self.withValue   action:@selector(collectNumber)];
    UIBarButtonItem *textButton  = [self addUIBarButtonWithImage:@"task-text"    enabled:self.withText    action:@selector(collectText)];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *buttons = [[NSArray alloc] initWithObjects:audioButton, flexButton, imageButton, flexButton, videoButton, flexButton, noteButton, flexButton, textButton, nil];
    
    [self setToolbarItems:buttons];
}

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Response"];
    
    [request setFetchBatchSize:8];
    
    if (self.run && self.run.runId) {
        NSMutableArray *tmp = [[NSMutableArray alloc] init];
        
        if (self.withPicture){
            tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:[NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:PHOTO]]]];
        }
        if (self.self.withVideo){
            tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:[NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:VIDEO]]]];
        }
        if (self.withAudio){
            tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:[NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:AUDIO]]]];
        }
        if (self.withText) {
            tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:[NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:TEXT]]]];
        }
        if (self.withValue) {
            tmp = [NSMutableArray arrayWithArray:[tmp arrayByAddingObject:[NSPredicate predicateWithFormat:@"responseType=%@", [NSNumber numberWithInt:NUMBER]]]];
        }
        
        // See http://stackoverflow.com/questions/4476026/add-additional-argument-to-an-existing-nspredicate
        NSPredicate *orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:tmp];
        NSPredicate *andPredicate = [NSPredicate predicateWithFormat: @"run.runId = %lld AND generalItem.generalItemId = %lld",[self.run.runId longLongValue], [self.generalItem.generalItemId longLongValue]];
        
        // Example Predicate: (run.runId == 5860462742732800 AND generalItem.generalItemId == 3713019) AND (contentType == "application/jpg" OR contentType == "video/quicktime" OR contentType == "audio/aac")
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:andPredicate, orPredicate, nil]];
        
        request.sortDescriptors = [NSArray arrayWithObjects:
                                   [NSSortDescriptor sortDescriptorWithKey:@"responseType"
                                                                 ascending:YES selector:@selector(compare:)],
                                   [NSSortDescriptor sortDescriptorWithKey:@"timeStamp"
                                                                 ascending:YES selector:@selector(compare:)],
                                   nil];
    } else if (self.account) {
        request.predicate = [NSPredicate predicateWithFormat:
                             @"account.localId = %@ AND account.accountType = %@ AND contentType !=nil AND responseType!= %@",
                             self.account.localId, self.account.accountType, [NSNumber numberWithInt:UNKNOWN]];
        
        request.sortDescriptors = [NSArray arrayWithObjects:
                                   [NSSortDescriptor sortDescriptorWithKey:@"timeStamp"
                                                                 ascending:YES selector:@selector(compare:)],
                                   nil];
    }
    
    if (self.run) {
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.run.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else if (self.account){
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.account.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        DLog(@"%@ - Neither account nor run is set.", NSLocalizedString(@"Error", @"Error"));
    }
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    self.fetchedResultsController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    [self.collectionView reloadData];
}

- (void)contextChanged:(NSNotification*)notification
{
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([notification object] == appDelegate.managedObjectContext) {
        return ;
    }
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    
    // Existing Code...
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    
    for(NSManagedObject *obj in updatedObjects){
        if ([[obj entity].name isEqualToString:@"GeneralItem"]) {
            GeneralItem* changedObject = (GeneralItem*) obj;
            if (self.generalItem == changedObject) {
                self.navigationItem.title = self.generalItem.name;
                
                DLog(@"TEXT='%@'", self.generalItem.richText);
                
#warning Replace the the TableView top Section.
                // self.webView loadHTMLString:self.generalItem.richText baseURL:nil];
            }
        }
    }
    
    // Existing Code...
    NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    
    for (NSManagedObject *obj in deletedObjects){
        if ([[obj entity].name isEqualToString:@"GeneralItem"]) {
            GeneralItem* changedObject = (GeneralItem*) obj;
            if (self.generalItem == changedObject) {
                
                DLog(@"little less easy... I was deleted");
                
                [self.navigationController popViewControllerAnimated:NO];
                [self dismissViewControllerAnimated:TRUE completion:nil];
            }
        }
    }
    
    // New Code.
    //    if ([ARLAppDelegate.theLock tryLock]) {
    //        [ARLAppDelegate.theLock unlock];
    
    // See if there are any Inquiry objects added and if so, reload the collectionView.
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    for(NSManagedObject *obj in insertedObjects){
        if ([[obj entity].name isEqualToString:@"Inquiry"]) {
            
            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];
            
            ELog(error);
            
            [self.collectionView reloadData];
            
            return;
        }
    }
    
    [self.fetchedResultsController fetchRequest];
    
    NSArray *indexPaths = [[NSArray alloc] init];
    BOOL fetched = NO;
    
    for(NSManagedObject *obj in updatedObjects){
        if ([[obj entity].name isEqualToString:@"Response"]) {
            if (!fetched) {
                NSError *error = nil;
                [self.fetchedResultsController performFetch:&error];
                fetched=YES;
            }
            
            Response *updated = (Response *)obj;
            
            //workaround for indexPathForObject:obj not working.
            for (Response *response in self.fetchedResultsController.fetchedObjects) {
                if ([response.objectID isEqual:updated.objectID]) {
                    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:response];
                    if (indexPath) {
                        indexPaths = [indexPaths arrayByAddingObject:indexPath];
                    }
                    break;
                }
            }
        }
    }
    
    if (indexPaths.count != 0) {
        [self.collectionView reloadData]; //reloadItemsAtIndexPaths:indexPaths];
    }
}

/*!
 *  See http://stackoverflow.com/questions/6469209/objective-c-where-to-remove-observer-for-nsnotification
 */
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.opaque = NO;
    self.collectionView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.run) {
        NSDictionary *jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:self.generalItem.json];
        
        self.navigationItem.title = self.generalItem.name;
        
        [self processJsonSetup:[jsonDict objectForKey:@"openQuestion"]];
        
        self.navigationController.toolbarHidden = NO;
    } else if (self.account) {
        self.navigationController.toolbarHidden = YES;
        self.withAudio = YES;
        self.withPicture = YES;
        self.withVideo = YES;
        self.withText = YES;
        self.withValue = YES;
    }
    
    [self setupFetchedResultsController];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (ARLNetwork.networkAvailable) {
        if (self.run) {
            // Collected Data
            if (self.withPicture) {
                [ARLFileCloudSynchronizer syncResponseData:self.run.managedObjectContext responseType:[NSNumber numberWithInt:PHOTO]];
            }
            if (self.withVideo) {
                [ARLFileCloudSynchronizer syncResponseData:self.run.managedObjectContext responseType:[NSNumber numberWithInt:VIDEO]];
            }
            if (self.withAudio) {
                [ARLFileCloudSynchronizer syncResponseData:self.run.managedObjectContext responseType:[NSNumber numberWithInt:AUDIO]];
            }
            if (self.withText) {
                // TODO Sync Text
            }
            if (self.withValue) {
                // TODO Sync Values
            }
        } else if (self.account) {
            // My Media
            [ARLFileCloudSynchronizer syncResponseData:self.account.managedObjectContext responseType:[NSNumber numberWithInt:PHOTO]];
            [ARLFileCloudSynchronizer syncResponseData:self.account.managedObjectContext responseType:[NSNumber numberWithInt:VIDEO]];
            [ARLFileCloudSynchronizer syncResponseData:self.account.managedObjectContext responseType:[NSNumber numberWithInt:AUDIO]];
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.fetchedResultsController = nil;
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionView Datasource

/*!
 *  The number of sections in a Collection.
 *
 *  see http://www.raywenderlich.com/22324/beginning-uicollectionview-in-ios-6-part-12
 *
 *  @param view The Table to be served.
 *
 *  @return The number of sections.
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)view
{
    return numResponses;
}

/*!
 *  Return the number of Rows in a Section of the Collection.
 *
 *  @param view The Collection to be served.
 *  @param section   The section of the data.
 *
 *  @return The number of Rows in the requested section.
 */
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    NSInteger *count = 0;
    
    switch (section){
        case RESPONSES:
            count = [self.fetchedResultsController.fetchedObjects count];
            break;
    }
    
    return count;
}

// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    switch (section){
//        case RESPONSES:
//            return @"";
//    }
//
//    // Error
//    return @"";
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ARLNarratorItemView *cell = (ARLNarratorItemView *)[cv dequeueReusableCellWithReuseIdentifier:self.cellIdentifier
                                                                                     forIndexPath:indexPath];
    
    
    cell.backgroundColor = [UIColor colorWithRed:(float)0xE6
                                           green:(float)0xE6
                                            blue:(float)0xFA
                                           alpha:1.0F];
    
    switch (indexPath.section) {
        case RESPONSES:{
            Response *response = (Response *)[self.fetchedResultsController objectAtIndexPath:indexPath];
            
            if (response.fileName) {
                
                if (self.withPicture && [response.responseType isEqualToNumber:[NSNumber numberWithInt:PHOTO]]) {
                    if (response.thumb) {
                        cell.imgView.image = [UIImage imageWithData:response.thumb];
                    } else if (response.data) {
                        cell.imgView.image = [UIImage imageWithData:response.data];
                    } else {
                        cell.imgView.Image = [UIImage imageNamed:@"task-photo"];
                    }
                } else if (self.withVideo && [response.responseType isEqualToNumber:[NSNumber numberWithInt:VIDEO]]) {
                    if (response.thumb) {
                        cell.imgView.image = [UIImage imageWithData:response.thumb];
                        
                        // rotate 90' Right (will al least make portrait videos right).
                        CGAffineTransform rotate = CGAffineTransformMakeRotation( M_PI / 2.0 );
                        [cell.imgView setTransform:rotate];
                        
                        // create a new bitmap image context
                        UIGraphicsBeginImageContext(cell.imgView.image.size);
                        
                        // draw original image into the context
                        [cell.imgView.image drawAtPoint:CGPointZero];
                        
                        // draw icon
                        UIImage *ico = [UIImage imageNamed:@"task-video-overlay"];
                        
                        // see http://stackoverflow.com/questions/8858404/uiimage-aspect-fit-when-using-drawinrect
                        CGFloat aspect = cell.imgView.image.size.width / cell.imgView.image.size.height;
                        
                        CGPoint p = CGPointMake(cell.imgView.image.size.width, cell.imgView.image.size.height);
                        
                        if (ico.size.width / aspect <= ico.size.width) {
                            CGSize s = CGSizeMake(ico.size.width, ico.size.width/(aspect));
                            [ico drawInRect:CGRectMake(p.x-s.width-2, 2, s.width, s.height)];
                        }else {
                            CGSize s = CGSizeMake(ico.size.height*aspect, ico.size.height);
                            [ico drawInRect:CGRectMake(p.x-s.width-2, 2, s.width, s.height)];
                        }
                        
                        // make image out of bitmap context
                        UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
                        
                        // free the context
                        UIGraphicsEndImageContext();
                        
                        cell.imgView.image = retImage;
                        //                  } else if (response.data) {
                        //                      cell.imgView.image = [UIImage imageWithData:response.data];
                    } else {
                        cell.imgView.Image = [UIImage imageNamed:@"task-video"];
                    }
                    //                  cell.imgView.image = [UIImage imageNamed:@"task-video"];
                } else if (self.withAudio && [response.contentType isEqualToString:@"audio/aac"]) {
                    cell.imgView.image = [UIImage imageNamed:@"task-record"];
                }
                
            } else {
                if (response.value) {
                    if ((self.withText  && [response.responseType isEqualToNumber:[NSNumber numberWithInt:TEXT]]) ||
                        (self.withValue && [response.responseType isEqualToNumber:[NSNumber numberWithInt:NUMBER]])) {
                        
                        NSString *txt;
                        NSError * error = nil;
                        NSData *JSONdata = [response.value dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONdata
                                                                                   options: NSJSONReadingMutableContainers
                                                                                     error:&error];
                        
                        if ([dictionary valueForKey:@"text"]) {
                            txt = [dictionary valueForKey:@"text"];
                        }else if ([dictionary valueForKey:@"value"]) {
                            txt = [dictionary valueForKey:@"value"];
                        }else {
                            txt = response.value;
                        }
                        
                        // Log(@"%f x %F", [self getCellSize].width, [self getCellSize].height);
                        
                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100,100), NO, 0.0);
                        cell.imgView.image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        cell.imgView.image  = [self drawText:txt inImage:cell.imgView.image atPoint:CGPointZero];
                    }
                }
            }
        }
            break;
    }
    
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)getCellSize {
    // noColumns
    CGFloat w = self.collectionView.bounds.size.width - ((self.noColumns) * self.columnInset);
    w /= self.noColumns;
    w-= 1 + (2 * self.noColumns);
    
    // 2
    CGSize retval = CGSizeMake(w, w);
    
    return retval;
}

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
   return [self getCellSize];
}

// 3
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(self.columnInset, self.columnInset, self.columnInset, self.columnInset);
}

// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Response *response = (Response *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (response.fileName) {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        
        INQWebViewController *controller = (INQWebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        
        if ([response.contentType isEqualToString:@"application/jpg"]) {
            controller.html = [NSString stringWithFormat:@"<!doctype html><html><head></head><body><img src='%@?thumbnail=1600&crop=true' style='width:100%%;' /></body></html>",
                               response.fileName];
        } else if ( [response.contentType isEqualToString:@"video/quicktime"]) {
            controller.html = [NSString stringWithFormat:@"<!doctype html><html><head></head><body><div style='text-align:center;'><video src='%@' controls autoplay width='%f' height='%f' /></div></body></html>",
                               response.fileName, size.width * screenScale, size.height * screenScale];
        } else if ( [response.contentType isEqualToString:@"audio/aac"]) {
            controller.html = [NSString stringWithFormat:@"<!doctype html><html><head></head><body><div style='text-align:center; margin-top:100px;'><audio src='%@' controls autoplay width='%f' height='%f' /></div></body></html>",
                               response.fileName, size.width * screenScale, size.height * screenScale];
        } else {
#warning TODO Add rending of text/value (or link to a popup)?
        }
        
        // DLog(@"%@", response.fileName);
        
        if (controller && controller.html) {
            [self.navigationController pushViewController:controller animated:TRUE];
        }
    } else {
#warning textarea does not forward clicks.
        // SEE http://iphonedevsdk.com/forum/iphone-sdk-development/82096-onclick-event-in-textfield.html
        //  (void)textFieldDidBeginEditing:(UITextField *)textField
        
        if (response.value) {
            NSError *error = nil;
            NSData *JSONdata = [response.value dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONdata
                                                                       options: NSJSONReadingMutableContainers
                                                                         error:&error];
            NSString *msg;
            
            if ([dictionary valueForKey:@"text"]) {
                msg = [dictionary valueForKey:@"text"];
            }else if ([dictionary valueForKey:@"value"]) {
                msg = [dictionary valueForKey:@"value"];
            }else {
                msg = response.value;
            }
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Value", @"Value")
                                                                  message:msg
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                        otherButtonTitles:nil, nil];
            [myAlertView show];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath :(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

-(UIImage *) drawText:(NSString*) text inImage:(UIImage*)image atPoint:(CGPoint)point
{
    //See http://stackoverflow.com/questions/4670851/nsstring-drawatpoint-blurry
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    
    //See http://stackoverflow.com/questions/4670851/nsstring-drawatpoint-blurry
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), true);
    
    //[image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    rect = CGRectInset(rect, 5, 5);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{
                                 // UIFont, default Helvetica(Neue) 12
                                 NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSBackgroundColorAttributeName: [UIColor whiteColor]
                                 };
    
    //    NSStringDrawingContext *drawingContext = [[NSStringDrawingContext alloc] init];
    //    drawingContext.minimumScaleFactor = 0.5; // Half the font siz
    
    [text drawInRect:rect withAttributes:attributes]; //CGRectIntegral(rect)

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark Collect Methods.

/*!
 *  Record Audio.
 */
- (void) collectAudio {
    ARLAudioRecorderViewController *controller = [[ARLAudioRecorderViewController alloc] init];
    
    controller.run = self.run;
    controller.generalItem = self.generalItem;
    
    [self.navigationController pushViewController:controller animated:TRUE];
}

/*!
 *  Request a Number.
 */
- (void) collectNumber
{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:self.valueDescription
                                                          message:NSLocalizedString(@"Enter Number", @"Enter Number")
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    
    //    self.valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    //    [self.valueTextField setBackgroundColor:[UIColor whiteColor]];
    //
    //    [myAlertView addSubview:self.valueTextField];
    
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    myAlertView.tag = 1;
    
    [myAlertView show];
}

/*!
 *  Request Text.
 */
- (void) collectText
{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:self.textDescription
                                                          message:NSLocalizedString(@"Enter Text",@"Enter Text")
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    
    myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    myAlertView.tag = 2;
    
    //self.valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    //[self.valueTextField setBackgroundColor:[UIColor whiteColor]];
    // see http://stackoverflow.com/questions/9407338/xcode-how-to-uialertview-with-a-text-field-on-a-loop-until-correct-value-en
    
    //[myAlertView addSubview:self.valueTextField];
    [myAlertView show];
}

/*!
 *  TODO
 *
 *  @param alertView   <#alertView description#>
 *  @param buttonIndex <#buttonIndex description#>
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"OK", @"OK")]) {
        UITextField *alertTextField = [alertView textFieldAtIndex:0];
        
        NSString *trimmed = [alertTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        switch (alertView.tag) {
            case 1: {
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                
                NSNumber *number = [formatter numberFromString:trimmed];
                
                if (number != nil) {
                    [Response createValueResponse: trimmed
                                          withRun:self.run
                                  withGeneralItem:self.generalItem ];
                } else {
                    // Invalid Number.
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                    message:NSLocalizedString(@"Invalid Number",@"Invalid Numbber")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
                break;
            case 2:
                [Response createTextResponse: trimmed
                                     withRun:self.run
                             withGeneralItem:self.generalItem ];
                break;
        }
        
        [Action initAction:@"answer_given"
                    forRun:self.run
            forGeneralItem:self.generalItem
    inManagedObjectContext:self.generalItem.managedObjectContext];
        
        NSError *error = nil;
        if (self.generalItem.managedObjectContext) {
            if ([self.generalItem.managedObjectContext hasChanges]){
                if (![self.generalItem.managedObjectContext save:&error]) {
                    [ARLNetwork ShowAbortMessage:error
                                            func:[NSString stringWithFormat:@"%s",__func__]];
                }
            }
        }
        if (ARLNetwork.networkAvailable) {
            [ ARLCloudSynchronizer syncResponses:self.generalItem.managedObjectContext];
        }
    }
}

/*!
 *  Record Video.
 */
- (void) collectVideo {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
        // [self presentModalViewController:self.imagePickerController animated:YES];
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

/*!
 *  Take a Picture.
 */
- (void) collectImage{
    if (!self.imagePickerController) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        }else
        {
            [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        
        // image picker needs a delegate so we can respond to its messages
        [self.imagePickerController setDelegate:self];
    }
    
    // Place image picker on the screen
    [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
}

/*!
 *  Handle recording of Videos and taking Photo with the iOS Api.
 *  Sync responses after selecting a Video or Photo.
 *
 *  @param picker <#picker description#>
 *  @param info   <#info description#>
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [Response createImageResponse:imageData
                                width:[NSNumber numberWithFloat:image.size.width]
                               height:[NSNumber numberWithFloat:image.size.height]
                              withRun:self.run
                      withGeneralItem:self.generalItem];
    } else {
        id object = [info objectForKey:UIImagePickerControllerMediaURL];
        
        DLog(@"Dict %@", info);
        DLog(@"Object %@", [object class ]);
        
        NSData* videoData = [NSData dataWithContentsOfURL:object];
        [Response createVideoResponse:videoData
                              withRun:self.run
                      withGeneralItem:self.generalItem];
        
        // [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    
    [Action initAction:@"answer_given" forRun:self.run forGeneralItem:self.generalItem inManagedObjectContext:self.generalItem.managedObjectContext];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    NSError *error = nil;
    if (self.generalItem.managedObjectContext) {
        if ([self.generalItem.managedObjectContext hasChanges]){
            if (![self.generalItem.managedObjectContext save:&error]) {
                [ARLNetwork ShowAbortMessage:error func:[NSString stringWithFormat:@"%s",__func__]];
            }
        }
        if (self.generalItem.managedObjectContext.parentContext) {
            if ([self.generalItem.managedObjectContext.parentContext hasChanges]){
                if (![self.generalItem.managedObjectContext.parentContext save:&error]) {
                    [ARLNetwork ShowAbortMessage:error func:[NSString stringWithFormat:@"%s",__func__]];
                }
            }
        }
        
        if (ARLNetwork.networkAvailable) {
            [ARLCloudSynchronizer syncResponses: self.generalItem.managedObjectContext];
        }
    }
}

@end
