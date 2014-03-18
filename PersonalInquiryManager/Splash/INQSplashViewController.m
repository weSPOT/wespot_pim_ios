//
//  IMViewController.m
//  InqueryManager
//
//  Created by Wim van der Vegt on 1/30/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "INQSplashViewController.h"

@interface INQSplashViewController ()

@property (strong, nonatomic) UIBarButtonItem *loginButton;
@property (strong, nonatomic) UIBarButtonItem *spacerButton;

@end

@implementation INQSplashViewController

#pragma - mark system

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.navigationController.toolbar.backgroundColor = [UIColor whiteColor];
    
    if (ARLNetwork.isLoggedIn) {
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
    _pageTitles = @[@"1-Over 200 Tips and Tricks", @"2-Discover Hidden Features", @"3-Bookmark Favorite Tip", @"4-Free Regular Update"];
    _pageImages = @[@"page1", @"page2", @"page3", @"page4"];

    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SplashPageViewController"];
    self.pageViewController.dataSource = self;
    
    INQSplashContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:NO];
    
    if (!self.loginButton) {
        self.spacerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(loginButtonButtonTap:)];
        
        self.toolbarItems = [NSArray arrayWithObjects:self.spacerButton, self.loginButton,nil];
    }
    
    [self addConstraints];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (INQSplashContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    INQSplashContentViewController *pageContentViewController = (INQSplashContentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SplashContentViewController"];
    
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((INQSplashContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((INQSplashContentViewController*) viewController).pageIndex;
    
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

- (IBAction)loginButtonButtonTap:(UIButton *)sender {
    if (ARLNetwork.networkAvailable) {
        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigation"];

        if (newViewController) {
            // Move to another UINavigationController or UITabBarController etc.
            // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
            [self.navigationController presentViewController:newViewController animated:YES  completion:nil];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Not online, login not possible" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void) addConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.backgroundImage,   @"background",
                                     nil];
    
    // Fails
    // for (UIView *view in [viewsDictionary keyEnumerator]) {
    //   view.translatesAutoresizingMaskIntoConstraints = NO;
    // }
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Size vertically
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"V:|[background]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"H:|[background]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

/*!
 *  Enable or Disable Login Button depending on Network availability.
 *
 *  @param note <#note description#>
 */
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability *reach = [note object];
    
    self.loginButton.enabled=[reach isReachable];
}

@end
