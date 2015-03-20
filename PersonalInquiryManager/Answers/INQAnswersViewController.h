//
//  INQQuestionViewController.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 5/21/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+UI.h"

@interface INQAnswersViewController : UITableViewController

@property (strong, nonatomic) NSArray *Answers;

@property (strong, nonatomic) NSString *Question;

@property (strong, nonatomic) NSString *Description;

@end
