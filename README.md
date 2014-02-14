APLSlideMenu
=========

Sliding Hamburger Menu like the one in the Facebook App

* supports optional swipe gesture support
* supports device orientations
* supports optional permanent display of slidemenu in landscape on iPad like an UISplitViewController
* supports iOS 7 View controller-based status bar appearance

## Installation
Install via cocoapods by adding this to your Podfile:

	pod "APLSlideMenu", "~> 0.0.9"

## Usage
Import header file:

	#import "APLSlideMenu.h"
	
APLSlideMenuViewController should be rootViewController and is initialized in your AppDelegate. This example code demonstrates the initialization with a storyboard:
	
	id rootViewController = self.window.rootViewController;
	
    if ([rootViewController isKindOfClass:[APLSlideMenuViewController class]]) {
        APLSlideMenuViewController *slideViewController = rootViewController;
        
        // first: configure the slide menu
        slideViewController.bouncing = YES;
        slideViewController.gestureSupport = APLSlideMenuGestureSupportDrag;
        
        // second: set the menuViewController
        slideViewController.menuViewController = [[slideViewController storyboard] instantiateViewControllerWithIdentifier:@"Menu"];
        
        // third: set the contentViewController
        slideViewController.contentViewController = [[slideViewController storyboard] instantiateViewControllerWithIdentifier:@"Content"];
        
    } else {
        NSLog(@"Ups, this shouldn't happen");
    }
