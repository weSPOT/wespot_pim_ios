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

@synthesize hypothesis = _hypothesis;
//@synthesize hypothesisView = _hypothesisView;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    
//    if (self) {
//        self.view.backgroundColor = [UIColor whiteColor];
//    }
//    
//    return self;
//}

- (void) setHypothesis:(NSString*) hypothesis {
    if (_hypothesis != hypothesis){
        _hypothesis = hypothesis;
    }
    
    NSLog(@"[%s] Loading %@", __func__, hypothesis);
    
    UIWebView *web = (UIWebView*) self.view;
    
    [web loadHTMLString:hypothesis  baseURL:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.hypothesisView = [[UIWebView alloc] init];
//    self.hypothesisView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.hypothesisView.backgroundColor = [UIColor redColor];
//    
//    [self.view addSubview:self.hypothesisView];
//    [self.hypothesisView loadHTMLString:_hypothesis baseURL:nil];
//	// Do any additional setup after loading the view.
//    
//    [self.view removeConstraints:[self.view constraints]];
//    
//    NSDictionary * viewsDictionary =
//    [[NSDictionary alloc] initWithObjectsAndKeys:
//     self.hypothesisView, @"hypothesisView", nil];
//    
//    NSString* verticalContstraint = @"V:|[hypothesisView]|";
//    
//    [self.view addConstraints:[NSLayoutConstraint
//                               constraintsWithVisualFormat:verticalContstraint
//                               options:NSLayoutFormatDirectionLeadingToTrailing
//                               metrics:nil
//                               views:viewsDictionary]];
//
//    NSString* horizontalContstraint = @"H:|[hypothesisView]|";
//    
//    [self.view addConstraints:[NSLayoutConstraint
//                               constraintsWithVisualFormat:horizontalContstraint
//                               options:NSLayoutFormatDirectionLeadingToTrailing
//                               metrics:nil
//                               views:viewsDictionary]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
