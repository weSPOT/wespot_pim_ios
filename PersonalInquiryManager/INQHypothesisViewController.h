//
//  INQHypothesisViewController.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INQHypothesisViewController : UIViewController

@property (strong, nonatomic)  NSString *hypothesis;

@property (strong, nonatomic) UIWebView *hypothesisView;


- (void) setHypothesis:(NSString*) hypothesis;
@end
