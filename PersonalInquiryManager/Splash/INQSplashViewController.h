//
//  IMViewController.h
//  InqueryManager
//
//  Created by Wim van der Vegt on 1/30/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIViewController+UI.h"

#import "Account+Create.h"
#import "INQSplashContentViewController.h"
#import "ARLNetwork+INQ.h"

@interface INQSplashViewController : UIViewController <UIPageViewControllerDataSource, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@end
