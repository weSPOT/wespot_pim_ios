//
//  INQInquiryPageViewController.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inquiry+Create.h"
#import "ARLNetwork+INQ.h"
#import "ARLCloudSynchronizer.h"
#import "Run+ARLearnBeanCreate.h"
#import "INQGeneralItemTableViewController.h"

@interface INQInquiryPageViewController : UIViewController

#warning this class seems to be unused (summary of a Inquiry)!

@property (strong, nonatomic)  Inquiry *inquiry;

@property (weak, nonatomic) UIButton *showDataCollection;
@property (weak, nonatomic) UIWebView *webView;
@property (weak, nonatomic) UIWebView *hypothesisView;
@end
