//
//  INQInquiryPageTableViewController.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+UI.h"

#import "Inquiry+Create.h"
#import "INQHypothesisViewController.h"
#import "INQPlanViewController.h"
#import "ARLNetwork+INQ.h"
#import "ARLCloudSynchronizer.h"
#import "Run+ARLearnBeanCreate.h"

@interface INQInquiryTableViewController : UITableViewController <UIWebViewDelegate>

@property (strong, nonatomic)  Inquiry *inquiry;

+(NSInteger) numParts;

@end
