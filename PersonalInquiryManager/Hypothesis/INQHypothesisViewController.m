//
//  INQHypothesisViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQHypothesisViewController.h"

@interface INQHypothesisViewController ()

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;

@end

@implementation INQHypothesisViewController

- (void) setHypothesis:(NSString*) hypothesis {
    if (_hypothesis != hypothesis){
        _hypothesis = hypothesis;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    // Add swipeGestures
    //    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
    //                                                     initWithTarget:self
    //                                                     action:@selector(oneFingerSwipeLeft:)];
    //    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    //    [self.view addGestureRecognizer:oneFingerSwipeLeft];
    //
    //    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
    //                                                      initWithTarget:self
    //                                                      action:@selector(oneFingerSwipeRight:)];
    //    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    //    [self.view addGestureRecognizer:oneFingerSwipeRight];
}

-(void)viewWillAppear:(BOOL)animated   {

}

-(void)viewDidAppear:(BOOL)animated {
    
    // NSLog(@"[%s] Loading %@", __func__, self.hypothesis);

    UIWebView *web = (UIWebView*) self.view;
    web.scrollView.contentInset = UIEdgeInsetsMake(self.navbarHeight + self.statusbarHeight, 0.0, 0.0, 0.0);
    
    //web.clipsToBounds = NO;
    web.delegate = self;
    
    [web loadHTMLString:self.hypothesis  baseURL:nil];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:self.hypothesis delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

//- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer {
//    // Insert your own code to handle swipe left
//    
//    NSLog(@"Swipe Left");
//    
//    UIViewController *newViewController;
//    
//    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//    [stackViewControllers removeLastObject];
//    
//    UIViewController *inquiryViewController = [stackViewControllers lastObject];
//    
//    if ([inquiryViewController respondsToSelector:@selector(nextPart)]) {
//        newViewController =  [inquiryViewController performSelector:@selector(nextPart)];
//    }
//    
//    if (newViewController) {
//        [stackViewControllers addObject:newViewController];
//        [self.navigationController setViewControllers:stackViewControllers animated:NO];
//    }
//}
//
//- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer {
//    // Insert your own code to handle swipe right
//
//    NSLog(@"Swipe Right");
//    
//    UIViewController *newViewController;
//    
//    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//    [stackViewControllers removeLastObject];
//    
//    UIViewController *inquiryViewController = [stackViewControllers lastObject];
//    
//    if ([inquiryViewController respondsToSelector:@selector(prevPart)]) {
//        newViewController =  [inquiryViewController performSelector:@selector(prevPart)];
//    }
//    
//    if (newViewController) {
//        [stackViewControllers addObject:newViewController];
//        [self.navigationController setViewControllers:stackViewControllers animated:NO];
//    }
//}

-(CGFloat) navbarHeight {
    return self.navigationController.navigationBar.bounds.size.height;
}

-(CGFloat) statusbarHeight
{
    // NOTE: Not always turned yet when we try to retrieve the height.
    return MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    // See http://stackoverflow.com/questions/4611940/uiwebview-loadhtmlstring-shows-blank-screen
//    return YES;
//}

@end
