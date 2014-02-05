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

- (void) setHypothesis:(NSString*) hypothesis {
    if (_hypothesis != hypothesis){
        _hypothesis = hypothesis;
    }
    
    NSLog(@"[%s] Loading %@", __func__, self.hypothesis);
    
    UIWebView *web = (UIWebView*) self.view;
    
    [web loadHTMLString:self.hypothesis  baseURL:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
