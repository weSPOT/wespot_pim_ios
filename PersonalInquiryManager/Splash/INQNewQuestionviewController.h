//
//  INQNewQuestionviewController.h
//  PersonalInquiryManager
//
//  Created by G.W. van der Vegt on 18/03/15.
//  Copyright (c) 2015 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPKeyboardAvoidingScrollView.h"

#import "UIViewController+UI.h"

#import "ARLNetwork+INQ.h"

@interface INQNewQuestionviewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSNumber *inquiryId;

@end
