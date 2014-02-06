//
//  ARLNarratorItemViewController.h
//  ARLearn
//
//  Created by Stefaan Ternier on 7/18/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralItem.h"
#import "GeneralItemData.h"
#import "ARLDataCollectionWidget.h"

@interface ARLNarratorItemViewController : UIViewController

@property (strong, nonatomic) GeneralItem * generalItem;
@property (strong, nonatomic) Run * run;

#warning this one can not easily be deleted (seems to be tied to a segue).
@property (weak, nonatomic) IBOutlet UINavigationItem *headerText;

@end
