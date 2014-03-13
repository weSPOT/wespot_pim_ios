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
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIWebView *web = (UIWebView*) self.view;
    web.scrollView.contentInset = UIEdgeInsetsMake(self.navbarHeight + self.statusbarHeight, 0.0, 0.0, 0.0);
    web.delegate = self;
    
    [web loadHTMLString:self.hypothesis baseURL:[[NSBundle mainBundle] bundleURL]];    
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(CGFloat) navbarHeight {
    return self.navigationController.navigationBar.bounds.size.height;
}

-(CGFloat) statusbarHeight
{
    // NOTE: Not always turned yet when we try to retrieve the height.
    return MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
}

@end
