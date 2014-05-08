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
#import "ARLAppDelegate.h"
#import "ARLNarratorItemView.h"
#import "INQWebViewController.h"

@interface ARLNarratorItemViewController : UICollectionViewController
<NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate>

@property (strong, nonatomic) GeneralItem *generalItem;
@property (strong, nonatomic) Run *run;

@property (strong, nonatomic) Account *account;

@end
