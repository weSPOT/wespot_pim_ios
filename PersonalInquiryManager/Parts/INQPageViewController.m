//
//  APPViewController.m
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "INQPageViewController.h"

@interface INQPageViewController ()

@property (strong, nonatomic) UIBarButtonItem *buttonFF;
@property (strong, nonatomic) UIBarButtonItem *buttonFB;

@end

@implementation INQPageViewController

#warning UIPageViewControl pages erratic when in scroll mode. Curl seems to be ok (but lacks the Page Control at the bottom).

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor colorWithRed:72.0F/255.0F green:125.0F/255.0F blue:185.0F/255.0F alpha:1.0F];
    
    self.dataSource = self;
    
    UIViewController *initialViewController = [self viewControllerAtIndex:[self.currentPageIndex unsignedIntValue]];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self didMoveToParentViewController:self];
    
    self.buttonFF = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                 target:self
                                                                 action:@selector(nextPage)];
    self.buttonFB = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                 target:self
                                                                 action:@selector(prevPage)];

    [self.navigationItem setRightBarButtonItems:[[NSArray alloc] initWithObjects:self.buttonFF, self.buttonFB, nil]];
    
    self.buttonFF.enabled = [self.currentPageIndex unsignedIntValue] != 4;
    self.buttonFB.enabled = [self.currentPageIndex unsignedIntValue] != 0;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)initWithInitialPage:(NSNumber *)index {
    self.currentPageIndex = index;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    UIViewController *newViewController;
    
    // Find the InqueryViewController as it hosts the code that creates the SubViews.
    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stackViewControllers removeLastObject];
    
    UIViewController *inquiryViewController = [stackViewControllers lastObject];
    
    // Ask the InqueryViewController to create and initialize the requested ViewController.
    if ([inquiryViewController respondsToSelector:@selector(CreateInquiryPartViewController:)]) {
          newViewController =  [inquiryViewController performSelector:@selector(CreateInquiryPartViewController:) withObject:[NSNumber numberWithUnsignedInteger:index]];
    }
    
    self.currentPageIndex = [NSNumber numberWithInteger:index];
    
    return newViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    UIViewController *view = nil;
    
    do {
        
        if ([self.currentPageIndex isEqualToNumber: [NSNumber numberWithUnsignedInteger:0]]) {
            return nil;
        }
        
        // Decrease the index by 1 to return
        self.currentPageIndex = [NSNumber numberWithUnsignedInteger:[self.currentPageIndex unsignedIntValue] - 1];
        
        NSLog(@"[%s] Showing Page: %@",__func__, self.currentPageIndex);
        
        view = [self viewControllerAtIndex:[self.currentPageIndex unsignedIntValue]];
    } while (!view);
    
#warning hardcoded highest page index

    self.buttonFF.enabled = [self.currentPageIndex unsignedIntValue] != 4;
    self.buttonFB.enabled = [self.currentPageIndex unsignedIntValue] != 0;
    
    return view;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    // Increase the index by 1 to return
    UIViewController *view = nil;
    
    // ßNSLog(@"[%s] Old Index: %d", __func__, [self.viewControllers indexOfObject:viewController]);
    
    do {
        if ([self.currentPageIndex isEqualToNumber: [NSNumber numberWithUnsignedInteger:5]]) {
            return nil;
        }
        
        self.currentPageIndex = [NSNumber numberWithUnsignedInteger:[self.currentPageIndex unsignedIntValue] + 1];
        
        NSLog(@"[%s] Showing Page: %@",__func__, self.currentPageIndex);
        
        view = [self viewControllerAtIndex:[self.currentPageIndex unsignedIntValue]];
    } while (!view);
    
#warning hardcoded highest page index
    
    self.buttonFF.enabled = [self.currentPageIndex unsignedIntValue] != 4;
    self.buttonFB.enabled = [self.currentPageIndex unsignedIntValue] != 0;
    
    return view;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
   
    // The number of items reflected in the page indicator.
    return 6;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
   
    // The selected item reflected in the page indicator.
    return [self.currentPageIndex unsignedIntValue];
}

-(void)setCurrentPageIndex:(NSNumber *)currentPageIndex
{
    _currentPageIndex= currentPageIndex;
}

-(void)nextPage {
    UIViewController *next = [self pageViewController:self viewControllerAfterViewController:[self viewControllerAtIndex:[self.currentPageIndex unsignedIntValue]]];
    
    if (next) {
        NSArray *viewControllers = [NSArray arrayWithObject:next];
        
        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
}

-(void)prevPage {
    UIViewController * prev = [self pageViewController:self viewControllerBeforeViewController:[self viewControllerAtIndex:[self.currentPageIndex unsignedIntValue]]];
    
    if (prev) {
        NSArray *viewControllers = [NSArray arrayWithObject:prev];
        
        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
}

@end
