//
//  ARLNarratorItemViewController.h
//  ARLearn
//
//  Created by Stefaan Ternier on 7/18/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "GeneralItem.h"
#import "GeneralItemData.h"
#import "Response+Create.h"
#import "GeneralItem+ARLearnBeanCreate.h"
#import "Run+ARLearnBeanCreate.h"
#import "ARLAudioRecorder.h"
#import "ARLAudioRecorderViewController.h"

@interface ARLNarratorItemViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) GeneralItem * generalItem;
@property (strong, nonatomic) Run * run;

#warning this one can not easily be deleted (seems to be tied to a segue).
//@property (weak, nonatomic) IBOutlet UINavigationItem *headerText;

#warning ARLDataCollectionWidget;
@property (nonatomic, readwrite) BOOL withAudio;
@property (nonatomic, readwrite) BOOL withPicture;
@property (nonatomic, readwrite) BOOL withText;
@property (nonatomic, readwrite) BOOL withValue;
@property (nonatomic, readwrite) BOOL withVideo;
@property (nonatomic, readwrite) BOOL isVisible;

@property (nonatomic, strong) UITextField *valueTextField;
@property (strong, nonatomic) UIImagePickerController * imagePickerController;
//@property (strong, nonatomic) UIViewController * generalItemViewController;

@property (nonatomic, strong) NSString *textDescription;
@property (nonatomic, strong) NSString *valueDescription;

//- (id) init : (NSDictionary *) jsonDict viewController: (UIViewController*) viewController;
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

@end
