//
//  INQQuestionViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 5/21/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQQuestionViewController.h"

@interface INQQuestionViewController ()

- (IBAction)submit:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation INQQuestionViewController

- (void) setQuestion:(NSString *) question {
    if (_question != question) {
        _question = question;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIWebView *web = (UIWebView*) self.view;
    
    // web.scrollView.contentInset = UIEdgeInsetsMake(self.navbarHeight + self.statusbarHeight, 0.0, 0.0, 0.0);
    
    web.backgroundColor = [UIColor whiteColor];
    web.delegate = self;
    
    if ([self.question length] ==0) {
        [web loadHTMLString:@"No question has been added yet for this inquiry." baseURL:[[NSBundle mainBundle] bundleURL]];
    }else {
        [web loadHTMLString:self.question baseURL:[[NSBundle mainBundle] bundleURL]];
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

- (IBAction)submit:(UIButton *)sender{
#warning Implement submitting a Question.
}

@end
