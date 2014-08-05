//
//  INQHypothesisViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQHypothesisViewController.h"

@interface INQHypothesisViewController ()

@end

@implementation INQHypothesisViewController

- (void) setHypothesis:(NSString *) hypothesis {
    if (_hypothesis != hypothesis){
        _hypothesis = hypothesis;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIWebView *web = (UIWebView*) self.view;
    
    web.scrollView.contentInset = UIEdgeInsetsMake(self.navbarHeight + self.statusbarHeight, 0.0, 0.0, 0.0);
    
    web.backgroundColor = [UIColor whiteColor];
    web.delegate = self;
    
    if ([self.hypothesis length] ==0) {
        [web loadHTMLString:@"No hypothesis has been added yet for this inquiry." baseURL:[[NSBundle mainBundle] bundleURL]];
    }else {
        [web loadHTMLString:self.hypothesis baseURL:[[NSBundle mainBundle] bundleURL]];
    }
}


/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
