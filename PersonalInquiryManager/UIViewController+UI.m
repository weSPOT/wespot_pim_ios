//
//  UIViewController_uistuff.c
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 7/3/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#include "UIViewController+UI.h"

//@interface UIViewController (UI)
//
//@end

@implementation UIViewController (UI)

/*!
 *  Getter
 *
 *  @return The NavBar Width.
 */
-(CGFloat) navbarWidth {
    return self.navigationController.navigationBar.bounds.size.width;
}

/*!
 *  Getter
 *
 *  @return The Status Bar Height.
 */
-(CGFloat) statusbarHeight
{
    // NOTE: Not always turned yet when we try to retrieve the height.
    return MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
}

/*!
 *  Getter
 *
 *  @return The Nav Bar Height.
 */
-(CGFloat) navbarHeight {
    return self.navigationController.navigationBar.bounds.size.height;
}

/*!
 *  Getter
 *
 *  @return The Tab Bar Height.
 */
-(CGFloat) tabbarHeight {
    return self.tabBarController.tabBar.bounds.size.height;
}

/*!
 *  Getter
 *
 *  @return The Current Orientation.
 */
-(UIInterfaceOrientation) interfaceOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

@end
