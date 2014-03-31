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

@property (nonatomic, strong) UITextField *valueTextField;
@property (strong, nonatomic) UIImagePickerController * imagePickerController;

@property (nonatomic, strong) NSString *textDescription;
@property (nonatomic, strong) NSString *valueDescription;

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;
@property (readonly, nonatomic) CGFloat tabbarHeight;

@property (readonly, nonatomic) UIInterfaceOrientation interfaceOrientation;
@property (readonly, nonatomic) NSString *cellIdentifier;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ARLNarratorItemViewController

@synthesize run = _run;
@synthesize generalItem = _generalItem;

@synthesize account = _account;

-(CGFloat) statusbarHeight
{
    // NOTE: Not always turned yet when we try to retrieve the height.
    return MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
}

-(CGFloat) navbarHeight {
    return self.navigationController.navigationBar.bounds.size.height;
}

-(CGFloat) tabbarHeight {
    return self.tabBarController.tabBar.bounds.size.height;
}

-(NSString*) cellIdentifier {
    return  @"responseItemCell";
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
    CGRect imageRect = CGRectMake(0.0f, 0.0f, inputImage.size.width, inputImage.size.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw a white background
    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(ctx, imageRect);
    
    // Draw the luminosity on top of the white background to get grayscale
    [inputImage drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0f];
    
    // Apply the source image's alpha
    [inputImage drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage* grayscaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return grayscaleImage;
}

-(UIInterfaceOrientation) interfaceOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

- (void) processJsonSetup:(NSDictionary *) jsonDict {
    self.isVisible = YES;
    
    self.withAudio = [(NSNumber*)[jsonDict objectForKey:@"withAudio"] intValue] ==1;
    self.withPicture = [(NSNumber*)[jsonDict objectForKey:@"withPicture"] intValue] ==1;
    self.withText = [(NSNumber*)[jsonDict objectForKey:@"withText"] intValue] ==1;
    self.withValue = [(NSNumber*)[jsonDict objectForKey:@"withValue"] intValue] ==1;
    self.withVideo = [(NSNumber*)[jsonDict objectForKey:@"withVideo"] intValue] ==1;
    
    self.textDescription = [jsonDict objectForKey:@"textDescription"];
    self.valueDescription = [jsonDict objectForKey:@"valueDescription"];
    
    UIBarButtonItem *audioButton = [self addUIBarButtonWithImage:@"task-record" enabled:self.withAudio action:@selector(collectAudio)];
    UIBarButtonItem *imageButton = [self addUIBarButtonWithImage:@"task-photo" enabled:self.withPicture action:@selector(collectImage)];
    UIBarButtonItem *videoButton = [self addUIBarButtonWithImage:@"task-video" enabled:self.withVideo action:@selector(collectVideo)];
    UIBarButtonItem *noteButton = [self addUIBarButtonWithImage:@"task-explore" enabled:self.withValue action:@selector(collectNumber)];
    UIBarButtonItem *textButton = [self addUIBarButtonWithImage:@"task-text" enabled:self.withText action:@selector(collectText)];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *buttons = [[NSArray alloc] initWithObjects:audioButton, flexButton, imageButton, flexButton, videoButton, flexButton, noteButton, flexButton, textButton, nil];
    
    [self setToolbarItems:buttons];
}

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Response"];
    
    [request setFetchBatchSize:8];
    
    if (self.run && self.run.runId) {
        NSString *contentType = @"";
        if (self.withPicture) {
            contentType = @"application/jpg";
        } else if (self.withVideo) {
            contentType = @"video/quicktime";
        } else if (self.withAudio) {
            contentType = @"audio/aac";
        }
        
        request.predicate = [NSPredicate predicateWithFormat:
                             @"run.runId = %lld AND contentType = %@",
                             [self.run.runId longLongValue], contentType];

        
        request.sortDescriptors = [NSArray arrayWithObjects:
                                   [NSSortDescriptor sortDescriptorWithKey:@"contentType"
                                                                 ascending:YES],
                                   [NSSortDescriptor sortDescriptorWithKey:@"timeStamp"
                                                                 ascending:YES],
                                   nil];
    } else if (self.account) {
        request.predicate = [NSPredicate predicateWithFormat:
                             @"account.localId = %@ AND account.accountType = %@ AND contentType !=nil AND contentType!=''",
                             self.account.localId, self.account.accountType];
        
        request.sortDescriptors = [NSArray arrayWithObjects:
                                   [NSSortDescriptor sortDescriptorWithKey:@"timeStamp"
                                                                 ascending:YES],
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
        NSLog(@"[%s] Error, netither account nor run is set.", __func__);
    }
    
    self.fetchedResultsController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
}

- (void)contextChanged:(NSNotification*)notification
{
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
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
                
                NSLog(@"[%s] TEXT='%@'",__func__, self.generalItem.richText);
                
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
                NSLog(@"little less easy... I was deleted");
                
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
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
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
    } else {
        self.navigationController.toolbarHidden = YES;
        self.withAudio = YES;
        self.withPicture = YES;
        self.withVideo = YES;
        //      self.withText = YES;
        //      self.withValue = YES;
    }
    
    [self setupFetchedResultsController];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
        if (ARLNetwork.networkAvailable) {
        if (self.run) {
            [ARLFileCloudSynchronizer syncResponseData:self.run.managedObjectContext];
        } else if (self.account) {
            [ARLFileCloudSynchronizer syncResponseData:self.account.managedObjectContext];
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    // Error
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
    ARLNarratorItemView *cell = (ARLNarratorItemView *)[cv dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:(float)0xE6
                                           green:(float)0xE6
                                            blue:(float)0xFA
                                           alpha:1.0F];

    switch (indexPath.section) {
        case RESPONSES:{
            Response *response = (Response *)[self.fetchedResultsController objectAtIndexPath:indexPath];

            if (response.fileName) {
                if (self.withPicture && [response.contentType isEqualToString:@"application/jpg"]) {
                    if (response.thumb) {
                        cell.imgView.image = [UIImage imageWithData:response.thumb];
                    } else if (response.data) {
                        cell.imgView.image = [UIImage imageWithData:response.data];
                    } else {
                        cell.imgView.Image = [UIImage imageNamed:@"task-photo"];
                    }
                } else if (self.withVideo && [response.contentType isEqualToString:@"video/quicktime"]) {
                    UIImage *icon =[UIImage imageNamed:@"task-video"];

                    cell.imgView.image = icon;
                } else if (self.withAudio && [response.contentType isEqualToString:@"audio/aac"]) {
                    UIImage *icon =[UIImage imageNamed:@"task-record"];
 
                    cell.imgView.image = icon;
                }
            }
        }
            break;
    }
    
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //    NSString *searchTerm = self.searches[indexPath.section];
    //
    //    FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
    
    // 2
    CGSize retval = /*photo.thumbnail.size.width > 0 ? photo.thumbnail.size :*/CGSizeMake(100, 100);
    retval.height += 35;
    retval.width += 35;
    
    return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
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
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
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
- (void) collectNumber{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:self.valueDescription message:@"Not implemented yet" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    self.valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    [self.valueTextField setBackgroundColor:[UIColor whiteColor]];
    
    [myAlertView addSubview:self.valueTextField];
    [myAlertView show];
}

/*!
 *  Request Text.
 */
- (void) collectText{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:self.textDescription message:@"Not implemented yet" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    self.valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    [self.valueTextField setBackgroundColor:[UIColor whiteColor]];
    
    [myAlertView addSubview:self.valueTextField];
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
    
    if ([title isEqualToString:@"OK"]) {
        [Response createTextResponse: self.valueTextField.text withRun:self.run withGeneralItem:self.generalItem ];
        [Action initAction:@"answer_given" forRun:self.run forGeneralItem:self.generalItem inManagedObjectContext:self.generalItem.managedObjectContext];
        
        NSError *error = nil;
        if (self.generalItem.managedObjectContext) {
            if ([self.generalItem.managedObjectContext hasChanges]){
                if (![self.generalItem.managedObjectContext save:&error]) {
                    NSLog(@"[%s] Unresolved error %@, %@", __func__, error, [error userInfo]);
                    abort();
                }
            }
        }
        
        [ ARLCloudSynchronizer syncResponses:self.generalItem.managedObjectContext];
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
            self.imagePickerController.cameraDevice =  UIImagePickerControllerCameraDeviceFront;
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
        [Response createImageResponse:imageData width:[NSNumber numberWithFloat:image.size.width] height:[NSNumber numberWithFloat:image.size.height]  withRun:self.run withGeneralItem:self.generalItem];
    } else {
        id object = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"[%s] dict %@", __func__, info);
        NSLog(@"[%s] object %@", __func__, [object class ]);
        NSData* videoData = [NSData dataWithContentsOfURL:object];
        [Response createVideoResponse:videoData withRun:self.run withGeneralItem:self.generalItem];
        
        //      [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    
    [Action initAction:@"answer_given" forRun:self.run forGeneralItem:self.generalItem inManagedObjectContext:self.generalItem.managedObjectContext];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    NSError *error = nil;
    if (self.generalItem.managedObjectContext) {
        if ([self.generalItem.managedObjectContext hasChanges]){
            if (![self.generalItem.managedObjectContext save:&error]) {
                NSLog(@"[%s] Unresolved error %@, %@", __func__, error, [error userInfo]);
                abort();
            }
        }
        if (self.generalItem.managedObjectContext.parentContext) {
            if ([self.generalItem.managedObjectContext.parentContext hasChanges]){
                if (![self.generalItem.managedObjectContext.parentContext save:&error]) {
                    NSLog(@"[%s] Unresolved error %@, %@", __func__, error, [error userInfo]);
                    abort();
                }
            }
        }
        
        [ARLCloudSynchronizer syncResponses: self.generalItem.managedObjectContext];
    }
}

@end
