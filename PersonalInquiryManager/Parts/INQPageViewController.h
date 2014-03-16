//
//  APPViewController.h
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INQPageViewController : UIPageViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) NSNumber *currentPageIndex;

@end
