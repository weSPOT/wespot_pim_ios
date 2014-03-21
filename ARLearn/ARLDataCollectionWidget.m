//
//  ARLDataCollectionWidget.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/11/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLDataCollectionWidget.h"

@implementation ARLDataCollectionWidget

@synthesize withAudio = _withAudio;
@synthesize withPicture = _withPicture;
@synthesize withText = _withText;
@synthesize withValue = _withValue;
@synthesize withVideo = _withVideo;

@synthesize isVisible = _isVisible;

@synthesize generalItem = _generalItem;
@synthesize run = _run;
@synthesize valueTextField = _valueTextField;
@synthesize imagePickerController = _imagePickerController;
@synthesize generalItemViewController = _generalItemViewController;

@synthesize textDescription = _textDescription;
@synthesize valueDescription = _valueDescription;

- (UIButton *)addButtonWithImage:(NSString *)imageString enabled:(BOOL)enabled action:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImage * image = [UIImage imageNamed:imageString];
    if (!enabled) {
        image = [self grayishImage:image];
    }
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setEnabled:enabled];
    
    return button;
}

// Transform the image in grayscale.
// See http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
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

- (id) init :(NSDictionary *) jsonDict viewController: (UIViewController*) viewController {
    
    if (self = [super init]) {
        _generalItemViewController = viewController;
        if (!jsonDict) {
            self.isVisible = NO;
            return self;
        }
        self.isVisible = YES;
        
        self.withAudio = [(NSNumber*)[jsonDict objectForKey:@"withAudio"] intValue] ==1;
        self.withPicture = [(NSNumber*)[jsonDict objectForKey:@"withPicture"] intValue] ==1;
        self.withText = [(NSNumber*)[jsonDict objectForKey:@"withText"] intValue] ==1;
        self.withValue = [(NSNumber*)[jsonDict objectForKey:@"withValue"] intValue] ==1;
        self.withVideo = [(NSNumber*)[jsonDict objectForKey:@"withVideo"] intValue] ==1;
        
        self.textDescription = [jsonDict objectForKey:@"textDescription"];
        self.valueDescription = [jsonDict objectForKey:@"valueDescription"];
        
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;  //This part hung me up
        
        UIButton *audioButton = [self addButtonWithImage:@"task-record" enabled:self.withAudio action:@selector(collectAudio)];
        UIButton *imageButton = [self addButtonWithImage:@"task-photo" enabled:self.withPicture action:@selector(collectImage)];
        UIButton *videoButton = [self addButtonWithImage:@"task-video" enabled:self.withVideo action:@selector(collectVideo)];
        UIButton *noteButton = [self addButtonWithImage:@"task-explore" enabled:self.withValue action:@selector(collectNumber)];
        UIButton *textButton = [self addButtonWithImage:@"task-text" enabled:self.withText action:@selector(collectText)];
        
        [self addSubview:audioButton];
        [self addSubview:imageButton];
        [self addSubview:videoButton];
        [self addSubview:noteButton];
        [self addSubview:textButton];
        
        NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         audioButton, @"audioButton",
                                         imageButton, @"imageButton",
                                         videoButton, @"videoButton",
                                         noteButton,  @"noteButton",
                                         textButton,  @"textButton",
                                         nil];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-[audioButton(==50)]"
                              options:0
                              metrics:nil
                              views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-[imageButton(==50)]"
                              options:0
                              metrics:nil
                              views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-[videoButton(==50)]"
                              options:0
                              metrics:nil
                              views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-[noteButton(==50)]"
                              options:0
                              metrics:nil
                              views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-[textButton(==50)]"
                              options:0
                              metrics:nil
                              views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:[audioButton(==50)]-5-[imageButton(==audioButton)]-5-[videoButton(==audioButton)]-5-[noteButton(==audioButton)]-5-[textButton(==audioButton)]"
                              options:0
                              metrics:nil
                              views:viewsDictionary]];
        
        NSLayoutConstraint *center = [NSLayoutConstraint
                                      constraintWithItem:videoButton attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self attribute:NSLayoutAttributeCenterX
                                      multiplier:1 constant:0];
        [self addConstraint:center];
    }
    return self;
}

- (void) collectAudio {
    ARLAudioRecorderViewController *controller = [[ARLAudioRecorderViewController alloc] init];
    controller.run = self.run;
    controller.generalItem = self.generalItem;
    
    [[self.generalItemViewController navigationController] pushViewController:controller animated:TRUE];
    //  [self.generalItemViewController presentViewController:controller animated:TRUE completion:nil];
}

- (void) collectNumber{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:self.valueDescription message:@"Not implemented yet" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    self.valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    [self.valueTextField setBackgroundColor:[UIColor whiteColor]];
    
    [myAlertView addSubview:self.valueTextField];
    [myAlertView show];
}

- (void) collectText{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:self.textDescription message:@"Not implemented yet" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    self.valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    [self.valueTextField setBackgroundColor:[UIColor whiteColor]];
    
    [myAlertView addSubview:self.valueTextField];
    [myAlertView show];
}


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
        
        //        [self presentModalViewController:self.imagePickerController animated:YES];
        [self.generalItemViewController presentViewController:self.imagePickerController animated:YES completion:nil];
        
    }
    //    if (!self.imagePickerController) {
    //        self.imagePickerController = [[UIImagePickerController alloc] init];
    //        if ([UIImagePickerController isCameraDeviceAvailable:[self.imagePickerController cameraDevice]]) {
    //            [self.imagePickerController takePicture];
    //
    //        }else
    //        {
    //            [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    //        }
    //
    //        // image picker needs a delegate so we can respond to its messages
    //        [self.imagePickerController setDelegate:self];
    //    }
    //    // Place image picker on the screen
    //    [self.generalItemViewController presentViewController:self.imagePickerController animated:YES completion:nil];
}

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
    [self.generalItemViewController presentViewController:self.imagePickerController animated:YES completion:nil];
}

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
    
    [self.generalItemViewController dismissViewControllerAnimated:YES completion:nil];
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
