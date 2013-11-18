//  Created by Tobias Conradi on 18.12.12.
//  Copyright (c) 2012 apploft GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


typedef NS_ENUM(NSInteger,APLSlideMenuGestureSupportType) {
    APLSlideMenuGestureSupportNone = 0,
    APLSlideMenuGestureSupportBasic,
    APLSlideMenuGestureSupportDrag
};

@class APLSlideMenuViewController;
@protocol TRUMainMenuViewControllerDelegate;

extern NSString *APLSlideMenuWillShowNotification;
extern NSString *APLSlideMenuDidShowNotification;
extern NSString *APLSlideMenuWillHideNotification;
extern NSString *APLSlideMenuDidHideNotification;

@protocol APLSlideMenuViewControllerDelegate<NSObject>
@optional
-(void) willShowMenu:(APLSlideMenuViewController *)aViewController;
-(void) didShowMenu:(APLSlideMenuViewController *)aViewController;
-(void) willHideMenu:(APLSlideMenuViewController *)aViewController;
-(void) didHideMenu:(APLSlideMenuViewController *)aViewController;
@end

/* To be implemented by any view controller who wants to influence 
   the gesture support for the slide menu when it's visible.
 */
@protocol APLSlideMenuGestureSupport <NSObject>
@optional
-(APLSlideMenuGestureSupportType)gestureSupport;
@end

@interface APLSlideMenuViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIViewController *menuViewController;
@property (nonatomic, strong) IBOutlet UIViewController *contentViewController;

/** Listen to show and hide events. */
@property (nonatomic, weak) id<APLSlideMenuViewControllerDelegate> slideDelegate;

/** Default: APLSlideMenuGestureSupportBasic */
@property (nonatomic, assign) APLSlideMenuGestureSupportType gestureSupport;

/**
 *  When set to YES the user can tap on the content view to hide the menu.
 *  @note: default value is YES
 */
@property (nonatomic, assign) BOOL tapOnContentViewToHideMenu;

/** Duration of all animations. */
@property (nonatomic, assign) NSTimeInterval animationDuration;

/** Width of menu. 0.0 - 1.0 are interpreted as relative width, all other as absolute width. */
@property (nonatomic, assign) CGFloat menuWidth;

/** Add a small bouncing animation as the slider glides into position. */
@property (nonatomic, assign, getter = isBouncing) BOOL bouncing;

/** always show menu like an UISplitViewController in landscape on iPad */
@property (nonatomic, assign, getter = isShowMenuInLandscape) BOOL showMenuInLandscape;

/** Set content view controller animated. */
- (void) setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated;

/** Readonly getter. */
- (BOOL) isMenuViewVisible;

- (void) showMenu:(BOOL)animated;
- (void) hideMenu:(BOOL)animated;

- (void) switchMenu:(BOOL) animated;

- (void) dismissContentViewController;
@end

//----------------------------------------------

/* Convenience category on UIViewController
 */
@interface UIViewController (APLSlideMenuViewController)

- (APLSlideMenuViewController*) slideMenuController;

@end
