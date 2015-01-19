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

@property (readwrite, nonatomic) UIImagePickerControllerCameraCaptureMode mode;

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation ARLNarratorItemViewController

@synthesize inquiry = _inquiry;
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
    
    if (self.inquiry && self.inquiry.run && self.inquiry.run.runId) {
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
        NSPredicate *andPredicate = [NSPredicate predicateWithFormat: @"run.runId = %lld AND generalItem.generalItemId = %lld",[self.inquiry.run.runId longLongValue], [self.generalItem.generalItemId longLongValue]];
        
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
    
    if (self.inquiry.run) {
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.inquiry.run.managedObjectContext
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
//    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
//    if ([notification object] == appDelegate.managedObjectContext) {
//        return ;
//    }
//    
//    if (![NSThread isMainThread]) {
//        [self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
//        return;
//    }
    
    // Existing Code...
//    @autoreleasepool {
//        NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
//        
//        for (NSManagedObject *obj in deletedObjects){
//            @autoreleasepool {
//                if ([[obj entity].name isEqualToString:@"GeneralItem"]) {
//                    GeneralItem* changedObject = (GeneralItem*) obj;
//                    if (self.generalItem == changedObject) {
//                        
//                        DLog(@"little less easy... I was deleted");
//                        
//                        [self.navigationController popViewControllerAnimated:NO];
//                        [self dismissViewControllerAnimated:TRUE completion:nil];
//                    }
//                }
//            }
//        }
//    }
    
    // New Code.
    //    if ([ARLAppDelegate.theLock tryLock]) {
    //        [ARLAppDelegate.theLock unlock];
    
    // See if there are any Inquiry objects added and if so, reload the collectionView.
//    @autoreleasepool {
//        NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
//        
//        for (NSManagedObject *obj in insertedObjects){
//            @autoreleasepool {
//                if ([[obj entity].name isEqualToString:@"Inquiry"]) {
//                    
//                    NSError *error = nil;
//                    [self.fetchedResultsController performFetch:&error];
//                    
//                    ELog(error);
//                    
//                    [self.collectionView reloadData];
//                    
//                    return;
//                }
//            }
//        }
//    }
    
//    [self.fetchedResultsController fetchRequest];
    
    // Existing Code...
//    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
//    
//    for(NSManagedObject *obj in updatedObjects){
//        if ([[obj entity].name isEqualToString:@"GeneralItem"]) {
//            GeneralItem* changedObject = (GeneralItem*) obj;
//            if (self.generalItem == changedObject) {
//                self.navigationItem.title = self.generalItem.name;
//                
//                DLog(@"TEXT='%@'", self.generalItem.richText);
//                
//                // warning Replace the the TableView top Section.
//                // self.webView loadHTMLString:self.generalItem.richText baseURL:nil];
//            }
//        }
//    }

//    @autoreleasepool {
//        NSArray *indexPaths = [[NSArray alloc] init];
//        BOOL fetched = NO;
//        
//        for(NSManagedObject *obj in updatedObjects) {
//            @autoreleasepool {
//                if ([[obj entity].name isEqualToString:@"Response"]) {
//                    if (!fetched) {
//                        NSError *error = nil;
//                        [self.fetchedResultsController performFetch:&error];
//                        fetched=YES;
//                    }
//                    
//                    Response *updated = (Response *)obj;
//                    
//                    // workaround for indexPathForObject:obj not working.
//                    for (Response *response in self.fetchedResultsController.fetchedObjects) {
//                        if ([response.objectID isEqual:updated.objectID]) {
//                            NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:response];
//                            if (indexPath) {
//                                indexPaths = [indexPaths arrayByAddingObject:indexPath];
//                            }
//                            break;
//                        }
//                    }
//                }
//            }
//        }
//        
//        
//        if (indexPaths.count != 0) {
//            [self.collectionView reloadData]; //reloadItemsAtIndexPaths:indexPaths];
//        }
//    }
    
    //[self.collectionView reloadData]; //reloadItemsAtIndexPaths:indexPaths];

    //    [self.fetchedResultsController fetchRequest];
    //
    //    [self.collectionView reloadData];
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
    
    if (self.inquiry.run) {
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
        if (self.inquiry.run) {
            if (self.withPicture) {
                [ARLFileCloudSynchronizer syncResponseData:self.inquiry.run.managedObjectContext
                                             generalItemId:self.generalItem.generalItemId
                                              responseType:[NSNumber numberWithInt:PHOTO]];
            }
            if (self.withVideo) {
                [ARLFileCloudSynchronizer syncResponseData:self.inquiry.run.managedObjectContext
                                             generalItemId:self.generalItem.generalItemId
                                              responseType:[NSNumber numberWithInt:VIDEO]];
            }
            if (self.withAudio) {
                [ARLFileCloudSynchronizer syncResponseData:self.inquiry.run.managedObjectContext
                                             generalItemId:self.generalItem.generalItemId
                                              responseType:[NSNumber numberWithInt:AUDIO]];
            }
            if (self.withText) {
                // TODO Sync Text
            }
            if (self.withValue) {
                // TODO Sync Values
            }
        } else if (self.account) {
            // My Media
            [ARLFileCloudSynchronizer syncMyResponseData:self.account.managedObjectContext
                                          responseType:[NSNumber numberWithInt:PHOTO]];
            [ARLFileCloudSynchronizer syncMyResponseData:self.account.managedObjectContext
                                          responseType:[NSNumber numberWithInt:VIDEO]];
            [ARLFileCloudSynchronizer syncMyResponseData:self.account.managedObjectContext
                                          responseType:[NSNumber numberWithInt:AUDIO]];
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.navigationController.toolbarHidden = YES;
    
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
    
    cell.imgView.frame = CGRectMake(0,0,
                                    cell.frame.size.width,
                                    cell.frame.size.height);
    
    @autoreleasepool {
        switch (indexPath.section) {
            case RESPONSES:{
                Response *response = (Response *)[self.fetchedResultsController objectAtIndexPath:indexPath];
                
                //            Log(@"%@ - %@ %@", response.fileName, response.value, response.contentType);
                
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
                        
                    } else if (self.withAudio && [response.responseType isEqualToNumber:[NSNumber numberWithInt:AUDIO]]) {
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
                                txt = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"value"]];
                            }else {
                                txt = [NSString stringWithFormat:@"%@", response.value];
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
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        ARLNarratorItemHeaderViewController *headerView = [collectionView
                                                           dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                           withReuseIdentifier:@"NarratorHeader"
                                                           forIndexPath:indexPath];
        
        if (self.inquiry.run) {
            NSString *description = [INQUtils cleanHtml:self.generalItem.richText];
            if ([description length] == 0) {
                [headerView.headerText setText:self.generalItem.name];
            } else {
                [headerView.headerText setText:description];
            }
        } else {
            [headerView.headerText setText: NSLocalizedString(@"My contributed items", @"My contributed items")];
        }
        
        reusableview = headerView;
    }
    
    //    if (kind == UICollectionElementKindSectionFooter) {
//        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
//        
//        reusableview = footerview;
//    }
    
    return reusableview;
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
        BOOL http = [[response.fileName lowercaseString] hasPrefix:@"http://"] || [[response.fileName lowercaseString] hasPrefix:@"https://"] ;
        
        // if (http) {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        
        INQWebViewController *controller = (INQWebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        
        switch ([response.responseType intValue]) {
            case PHOTO: {
                if (http && ARLNetwork.networkAvailable /*&& !response.thumb*/) {
                    controller.html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head></head><body><img src='%@?thumbnail=1600&crop=true' style='width:100%%;' /></body></html>",
                                       response.fileName];
                } else {
                    // NSString *strEncoded = [Base64 encode:data];
                    controller.html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head></head><body><img src='data:%@;base64,%@' style='width:100%%;' /></body></html>",
                                       response.contentType,
                                       [INQUtils base64forData:response.thumb]];
                }
            }
                break;
                
            case VIDEO: {
                // See http://www.iandevlin.com/blog/2012/09/html5/html5-media-and-data-uri
                controller.html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head></head><body><div style='text-align:center;'><video src='%@' controls autoplay width='%f' height='%f' /></div></body></html>",
                                   response.fileName, size.width * screenScale, size.height * screenScale];
            }
                break;
                
            case AUDIO: {
                Log(@"%@", response.fileName);
                controller.html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><script type='text/javascript'>function play() { document.getElementById('audio').play();}</script></head><body onload='play();'><div style='text-align:center; margin-top:100px;'><audio id='audio' src='%@' controls></audio></div><br/><br/><br/><hr/><div><h1 style='text-align: center;'>%@</h1></div></body></html>",
                                   response.fileName, [response.fileName pathExtension]];
                /*
                NSError *error = nil;
                
                // See http://www.raywenderlich.com/69369/audio-tutorial-ios-playing-audio-programatically-2014-edition
                self.audioSession = [AVAudioSession sharedInstance];
                [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
                
                ELog(error);
                
                NSString *audioString = [response.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *audioUrl = [[NSURL alloc] initWithString:audioString];
                NSData *audioFile = [[NSData alloc] initWithContentsOfURL:audioUrl options:NSDataReadingMappedIfSafe error:&error];

                self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioFile error:&error];
                self.audioPlayer.volume=1.0;
                
                [self.audioPlayer prepareToPlay];
                [self.audioPlayer play];
                 */
            }
                break;
        }
        
        if (controller && controller.html) {
            [self.navigationController pushViewController:controller animated:FALSE];
        } else {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PIM", @"PIM")
                                                                  message:NSLocalizedString(@"NotSynced", @"NotSynced")
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                        otherButtonTitles:nil, nil];
            [myAlertView show];
        }

    } else {
        
        //TODO: Textarea does not forward clicks.
        
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
            } else if ([dictionary valueForKey:@"value"]) {
                msg = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"value"]];
            } else {
                msg = [NSString stringWithFormat:@"%@", response.value];
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
    
    controller.inquiry = self.inquiry;
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
 *  Click At Button Handler.
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
                                          withRun:self.inquiry.run
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
                                     withRun:self.inquiry.run
                             withGeneralItem:self.generalItem ];
                break;
        }
        
        [Action initAction:@"answer_given"
                    forRun:self.inquiry.run
            forGeneralItem:self.generalItem
    inManagedObjectContext:self.generalItem.managedObjectContext];
        
        [INQLog SaveNLogAbort:self.generalItem.managedObjectContext func:[NSString stringWithFormat:@"%s",__func__]];
        
        if (ARLNetwork.networkAvailable) {
            [ ARLCloudSynchronizer syncResponses:self.generalItem.managedObjectContext];
        }
    }
}

/*!
 *  Record Video.
 */
- (void) collectVideo {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        
        // self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        self.mode = UIImagePickerControllerCameraCaptureModeVideo;
        
        self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            self.imagePickerController.cameraDevice= UIImagePickerControllerCameraDeviceRear;
        } else {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

/*!
 *  Take a Picture.
 */
- (void) collectImage {
    if (!self.imagePickerController) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        
        // self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        self.mode = UIImagePickerControllerCameraCaptureModePhoto;

        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
//    NSString *url = [info objectForKey:UIImagePickerControllerReferenceURL];

//    DLog(@"Image Url: %@", url);
    
    // see http://stackoverflow.com/questions/3837115/display-image-from-url-retrieved-from-alasset-in-iphone
    // see http://stackoverflow.com/questions/8085267/load-an-image-to-uiimage-from-a-file-path-to-the-asset-library
    
    // url = assets-library://asset/asset.JPG?id=A4ECA96B-4B7B-43B7-B3A0-3D83FDEC68B6&ext=JPG
    
    if (image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [Response createImageResponse:imageData
                                width:[NSNumber numberWithFloat:image.size.width]
                               height:[NSNumber numberWithFloat:image.size.height]
                              withRun:self.inquiry.run
                      withGeneralItem:self.generalItem];
    } else {
        id object = [info objectForKey:UIImagePickerControllerMediaURL];
        
        DLog(@"Dict %@", info);
        DLog(@"Object %@", [object class ]);
        
        NSData* videoData = [NSData dataWithContentsOfURL:object];
        [Response createVideoResponse:videoData
                              withRun:self.inquiry.run
                      withGeneralItem:self.generalItem];
        
        // [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    
    [Action initAction:@"answer_given" forRun:self.inquiry.run forGeneralItem:self.generalItem inManagedObjectContext:self.generalItem.managedObjectContext];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.generalItem.managedObjectContext) {
        [INQLog SaveNLogAbort:self.generalItem.managedObjectContext func:[NSString stringWithFormat:@"%s",__func__]];
        
        [self.generalItem.managedObjectContext.parentContext performBlock:^{
            [INQLog SaveNLogAbort:self.generalItem.managedObjectContext.parentContext func:[NSString stringWithFormat:@"%s",__func__]];
        }];
        
        if (ARLNetwork.networkAvailable) {
            [ARLCloudSynchronizer syncResponses: self.generalItem.managedObjectContext];
        }
    }
}

// See http://stackoverflow.com/questions/8528880/enabling-the-photo-library-button-on-the-uiimagepickercontroller
- (void) navigationController: (UINavigationController *)navigationController
       willShowViewController: (UIViewController *)viewController
                     animated: (BOOL) animated {
    
    // 1) video/photo
    // 2) video -> front/back (standard user-ineterface)
    // 3) photo -> camera/roll/library front/back (not available as the navigationbar obscures the default interface!)
    
    // Camera Available.
    switch (self.mode) {
            
            // Photo
        case UIImagePickerControllerCameraCaptureModePhoto:
            
            switch (self.imagePickerController.sourceType) {
                    
                    // Library
                case UIImagePickerControllerSourceTypePhotoLibrary: {
                    UIBarButtonItem* cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtn:)];
                    
                    viewController.toolbarItems = [NSArray arrayWithObject:cancelbutton];
                    
                    viewController.navigationController.toolbarHidden = NO;
                    
                    UIBarButtonItem* cambutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
                    UIBarButtonItem* rollbutton = [[UIBarButtonItem alloc] initWithTitle:@"Roll" style:UIBarButtonItemStylePlain target:self action:@selector(showRoll:)];
                    
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cambutton, rollbutton, nil];
                    } else {
                        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: rollbutton, nil];
                    }
                }
                    break;
                    
                    // Camera
                case UIImagePickerControllerSourceTypeCamera:
                {
                    viewController.navigationController.toolbarHidden = YES;
                    
                    UIBarButtonItem* libbutton = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary:)];
                    UIBarButtonItem* rollbutton = [[UIBarButtonItem alloc] initWithTitle:@"Roll" style:UIBarButtonItemStylePlain target:self action:@selector(showRoll:)];
                    
                    viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:libbutton, rollbutton, nil];
                    
                    viewController.navigationItem.title = @"Take Photo";
                    viewController.navigationController.navigationBarHidden = NO;
                }
                    break;
                    
                    // Saved Photo's.
                case UIImagePickerControllerSourceTypeSavedPhotosAlbum: {
                    UIBarButtonItem* cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtn:)];
                    
                    viewController.toolbarItems = [NSArray arrayWithObject:cancelbutton];
                    
                    viewController.navigationController.toolbarHidden = NO;
                    
                    UIBarButtonItem* cambutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
                    UIBarButtonItem* libbutton = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary:)];
                    
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cambutton, libbutton, nil];
                    } else {
                        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: libbutton, nil];
                    }
                }
                    break;
            }
            break;
            
            // Video
        case UIImagePickerControllerCameraCaptureModeVideo:
            //
            break;
    }
}

// See http://stackoverflow.com/questions/8528880/enabling-the-photo-library-button-on-the-uiimagepickercontroller
- (void) showCamera: (id) sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
}

// See http://stackoverflow.com/questions/8528880/enabling-the-photo-library-button-on-the-uiimagepickercontroller
- (void) showLibrary: (id) sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

// See http://stackoverflow.com/questions/8528880/enabling-the-photo-library-button-on-the-uiimagepickercontroller
- (void) showRoll: (id) sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}

// See http://stackoverflow.com/questions/8528880/enabling-the-photo-library-button-on-the-uiimagepickercontroller
- (void) cancelBtn: (id) sender {
    // self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self.imagePickerController dismissViewControllerAnimated:YES completion:NULL];
}


@end
