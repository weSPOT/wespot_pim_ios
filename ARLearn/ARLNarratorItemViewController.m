//
//  ARLNarratorItemViewController.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/18/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLNarratorItemViewController.h"

@interface ARLNarratorItemViewController ()

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;
@property (readonly, nonatomic) CGFloat tabbarHeight;
@property (readonly, nonatomic) UIInterfaceOrientation interfaceOrientation;

//@property (strong, nonatomic)  UIWebView *webView;
//@property (strong, nonatomic)  ARLDataCollectionWidget* dataCollectionWidget;

@end

@implementation ARLNarratorItemViewController

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

/*!
 *  Create a UIBarButton with a background image depending on the enabled state.
 *
 *  See http://stackoverflow.com/questions/7101608/setting-image-for-uibarbuttonitem-image-stretched
 *
 *  @param imageString <#imageString description#>
 *  @param enabled     <#enabled description#>
 *  @param selector    <#selector description#>
 *
 *  @return <#return value description#>
 */
- (UIBarButtonItem *)addUIBarButtonWithImage:(NSString *)imageString enabled:(BOOL)enabled action:(SEL)selector {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
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
 *  Transform the image in grayscale.
 *
 *  See http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
 *
 *  @param inputImage <#inputImage description#>
 *
 *  @return <#return value description#>
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

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) processJsonSetup:(NSDictionary *) jsonDict {
    //        if (!jsonDict) {
    //            self.isVisible = NO;
    //            return self;
    //        }
    self.isVisible = YES;
    
    self.withAudio = [(NSNumber*)[jsonDict objectForKey:@"withAudio"] intValue] ==1;
    self.withPicture = [(NSNumber*)[jsonDict objectForKey:@"withPicture"] intValue] ==1;
    self.withText = [(NSNumber*)[jsonDict objectForKey:@"withText"] intValue] ==1;
    self.withValue = [(NSNumber*)[jsonDict objectForKey:@"withValue"] intValue] ==1;
    self.withVideo = [(NSNumber*)[jsonDict objectForKey:@"withVideo"] intValue] ==1;
    
    self.textDescription = [jsonDict objectForKey:@"textDescription"];
    self.valueDescription = [jsonDict objectForKey:@"valueDescription"];
    
    //      self.backgroundColor = [UIColor clearColor];
    //      self.translatesAutoresizingMaskIntoConstraints = NO;  //This part hung me up
    
    UIBarButtonItem *audioButton = [self addUIBarButtonWithImage:@"task-record" enabled:self.withAudio action:@selector(collectAudio)];
    UIBarButtonItem *imageButton = [self addUIBarButtonWithImage:@"task-photo" enabled:self.withPicture action:@selector(collectImage)];
    UIBarButtonItem *videoButton = [self addUIBarButtonWithImage:@"task-video" enabled:self.withVideo action:@selector(collectVideo)];
    UIBarButtonItem *noteButton = [self addUIBarButtonWithImage:@"task-explore" enabled:self.withValue action:@selector(collectNumber)];
    UIBarButtonItem *textButton = [self addUIBarButtonWithImage:@"task-text" enabled:self.withText action:@selector(collectText)];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *buttons = [[NSArray alloc] initWithObjects:audioButton, flexButton, imageButton, flexButton, videoButton, flexButton, noteButton, flexButton, textButton, nil];
    
    [self setToolbarItems:buttons];
    //    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:self.generalItem.json];
    
#warning Replace the the TableView top Section.
    // self.headerText.title = self.generalItem.name;
    
    [self processJsonSetup:[jsonDict objectForKey:@"openQuestion"]];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataModelChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.generalItem.managedObjectContext];
}

- (void)handleDataModelChange:(NSNotification *)note
{
    NSSet *updatedObjects = [[note userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *deletedObjects = [[note userInfo] objectForKey:NSDeletedObjectsKey];
    
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

    for(NSManagedObject *obj in deletedObjects){
        if ([[obj entity].name isEqualToString:@"GeneralItem"]) {
            GeneralItem* changedObject = (GeneralItem*) obj;
            if (self.generalItem == changedObject) {
                NSLog(@"little less easy... I was deleted");

                [self.navigationController popViewControllerAnimated:NO];
                [self dismissViewControllerAnimated:TRUE completion:nil];
            }
        }
    }
}

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
