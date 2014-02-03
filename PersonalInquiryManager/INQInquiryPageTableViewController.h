//
//  INQInquiryPageTableViewController.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INQInquiryPartCell.h"
#import "Inquiry+Create.h"
#import "INQHypothesisViewController.h"
#import "INQNotesViewController.h"
#import "ARLNetwork+INQ.h"
#import "ARLCloudSynchronizer.h"
#import "Run+ARLearnBeanCreate.h"
#import "INQGeneralItemTableViewController.h"

@interface INQInquiryPageTableViewController : UITableViewController
@property (strong, nonatomic)  Inquiry *inquiry;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UIWebView *inquiryDescription;

@end
