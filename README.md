APLSlideMenu
=========

Sliding Hamburger Menu like the one in the Facebook App

* supports left and right slide menus
* supports optional swipe gesture support
* supports device orientations
* supports optional permanent display of slidemenu in landscape on iPad like an UISplitViewController
* supports iOS 7 View controller-based status bar appearance

## Installation
Install via cocoapods by adding this to your Podfile:

	pod "APLSlideMenu"

## Usage
Import header file:

	#import "APLSlideMenu.h"
	
APLSlideMenuViewController should be rootViewController and is initialized in your AppDelegate (or an APLSlideMenu subclass). This example code demonstrates the initialization with a storyboard:
	
	id rootViewController = self.window.rootViewController;
	
    if ([rootViewController isKindOfClass:[APLSlideMenuViewController class]]) {
        APLSlideMenuViewController *slideViewController = rootViewController;
        
        // first: configure the slide menu
        slideViewController.bouncing = YES;
        slideViewController.gestureSupport = APLSlideMenuGestureSupportDrag;
        
        // second: set the leftMenuViewController and / or rightMenuViewController
        slideViewController.leftMenuViewController = [[slideViewController storyboard] instantiateViewControllerWithIdentifier:@"LeftMenu"];
        slideViewController.rightMenuViewController = [[slideViewController storyboard] instantiateViewControllerWithIdentifier:@"RightMenu"];
        
        // third: set the contentViewController
        slideViewController.contentViewController = [[slideViewController storyboard] instantiateViewControllerWithIdentifier:@"Content"];
        
    } else {
        NSLog(@"Ups, this shouldn't happen");
    }

## Migration from earlier versions

### From 0.0.x

* rename `menuViewController` property to `leftMenuViewController`
* rename `showMenu:` method calls to `showLeftMenu:`
* rename `switchMenu:` method calls to `switchLeftMenu:`
