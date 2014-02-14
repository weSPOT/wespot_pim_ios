//
//  IMViewController.m
//  InqueryManager
//
//  Created by Wim van der Vegt on 1/30/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "INQSplashImageViewController.h"

@interface INQSplashImageViewController ()

@end

@implementation INQSplashImageViewController

#pragma - mark system

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchCurrentAccount];
    
    if (self.isLoggedIn == [NSNumber numberWithBool:YES]) {
        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
        
        if (newViewController) {
            // Move to another UINavigationController or UITabBarController etc.
            // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
            [self.navigationController presentViewController:newViewController animated:YES  completion:nil];
        }

        return;
    }
    
	// Do any additional setup after loading the view, typically from a nib.
    
    // Create the data model
    _pageTitles = @[@"Over 200 Tips and Tricks", @"Discover Hidden Features", @"Bookmark Favorite Tip", @"Free Regular Update"];
    _pageImages = @[@"page1.png", @"page2.png", @"page3.png", @"page4.png"];

    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    
//    // see http://stackoverflow.com/questions/4980610/implementing-a-splash-screen-in-ios
//    //     	http://stackoverflow.com/questions/8303155/adding-splashscreen-to-iphone-app-in-appdelegate
//    UIImage *splash = [UIImage imageNamed:@"arlearn_logo.png"];
//
//    UIImageView *imageViewFade=[[UIImageView alloc]initWithImage:splash];
//    UIImageView *imageViewBack=[[UIImageView alloc]initWithImage:splash];
//
//    [self.view insertSubview:imageViewBack atIndex: 0];
//
//    [self.view addSubview:imageViewFade];
//    [self.view bringSubviewToFront:imageViewFade];
//
//    // Now fade out splash image
//    [UIView transitionWithView:self.view duration:5.0f options:UIViewAnimationOptionTransitionNone
//        animations:^(void) {
//            imageViewFade.alpha=0.0f;
//        }
//        completion:^(BOOL finished) {
//            [imageViewFade removeFromSuperview];
//          
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
//                
//                if (newViewController) {
//                    // Move to another UINavigationController or UITabBarController etc.
//                    // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
//                    [self.navigationController presentViewController:newViewController animated:YES  completion:nil];
//                }
//            });
//       }];
}

-(void)viewDidAppear:(BOOL)animated {
//    [self.navigationItem setHidesBackButton:YES animated:YES];
//    self.navigationController.navigationBar.hidden = YES;
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

/*!
 *  Sets the isLoggedIn property of the AppDelegate.
 */
- (NSNumber *)isLoggedIn {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    return [appDelegate performSelector:@selector(isLoggedIn) withObject: nil];
}

- (Account *) fetchCurrentAccount {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    return [appDelegate performSelector:@selector(fetchCurrentAccount) withObject:nil];
}

- (IBAction)startWalkthrough:(id)sender {
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

- (IBAction)startPIM:(id)sender {
    UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
    
    if (newViewController) {
        // Move to another UINavigationController or UITabBarController etc.
        // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
        [self.navigationController presentViewController:newViewController animated:YES  completion:nil];
    }
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
