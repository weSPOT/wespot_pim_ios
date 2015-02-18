//
//  ARLDescriptionViewController.h
//  PersonalInquiryManager
//
//  Created by G.W. van der Vegt on 18/02/15.
//  Copyright (c) 2015 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+UI.h"

@interface INQDescriptionViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *Description;

@end
