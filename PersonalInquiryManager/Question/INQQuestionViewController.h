//
//  INQQuestionViewController.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 5/21/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+UI.h"

@interface INQQuestionViewController : UITableViewController

@property (strong, nonatomic) NSArray *Questions;

@property (strong, nonatomic) NSArray *Answers;

@end
