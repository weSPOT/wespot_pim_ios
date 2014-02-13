//
//  INQInquiryPageTableViewController.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INQInquiryTableViewItemCell.h"
#import "Inquiry+Create.h"
#import "INQHypothesisViewController.h"
#import "INQPlanViewController.h"
#import "ARLNetwork+INQ.h"
#import "ARLCloudSynchronizer.h"
#import "Run+ARLearnBeanCreate.h"

@interface INQInquiryTableViewController : UITableViewController

@property (strong, nonatomic)  Inquiry *inquiry;

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UIWebView *inquiryDescription;

@property (nonatomic) NSInteger currentPart;

- (UIViewController *)nextPart;
- (UIViewController *)prevPart;

@end
