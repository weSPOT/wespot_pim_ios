//
//  INQLoginViewController.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/11/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+UI.h"

#import "Account.h"
#import "ARLOauthWebViewController.h"
#import "ARLAccountDelegator.h"
#import "ComboBox.h"
#import "ARLNetwork+INQ.h"

@interface INQLoginViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDataDelegate,UIPickerViewDataSource, UIPickerViewDelegate> {
    
    NSArray *_pickerData;
}

/*!
 *  ID's and order of the cells.
 
 *  Must match ARLNetwork oauthInfo!
 */
typedef NS_ENUM(NSInteger, services) {
    /*!
     *  Internal (Admin).
     */
    INTERNAL = 0,
    /*!
     *  Facebook.
     */
    FACEBOOK = 1,
    /*!
     *  Google.
     */
    GOOGLE,
    /*!
     *  Linked-in
     */
    LINKEDIN,
    /*!
     *  Twitter.
     */
    TWITTER,
    /*!
     *  WeSpot.
     */
    WESPOT,
    /*!
     *  Number of oAuth Services.
     */
    numServices
};

@end
