//
//  INQLoginViewController.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/11/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Account.h"
#import "ARLOauthWebViewController.h"
#import "ARLAccountDelegator.h"

@interface INQLoginViewController : UIViewController  <UITextFieldDelegate, NSURLConnectionDataDelegate>

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
