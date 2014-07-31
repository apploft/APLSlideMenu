//
//  APLViewController.m
//  APLSlideMenuDemo
//
//  Created by Tobias Conradi on 18.12.12.
//  Copyright (c) 2012 apploft GmbH. All rights reserved.
//

#import "APLViewController.h"
#import "APLSlideMenuViewController.h"

@interface APLViewController ()

@end

@implementation APLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.slideMenuController.bouncing = YES;
    self.slideMenuController.gestureSupport = APLSlideMenuGestureSupportDrag;
    self.slideMenuController.separatorColor = [UIColor grayColor];
}

- (void)showLeftMenu:(id)sender {
    [self.slideMenuController showLeftMenu:YES];
}

- (void)showRightMenu:(id)sender {
    [self.slideMenuController showRightMenu:YES];
}

- (IBAction)gestureSupportChanged:(UISegmentedControl*)sender {
    NSInteger index = sender.selectedSegmentIndex;
    APLSlideMenuGestureSupportType support = APLSlideMenuGestureSupportNone;
    if (index == 0) {
        support = APLSlideMenuGestureSupportDrag;
    } else if (index == 1) {
        support = APLSlideMenuGestureSupportBasic;
    }
    self.slideMenuController.gestureSupport = support;
}

- (IBAction)toggleLeftMenuInLandscape:(UIButton*)sender {
    sender.selected = !sender.selected;
    self.slideMenuController.showLeftMenuInLandscape = sender.selected;
}

- (IBAction)toggleRightMenuInLandscape:(UIButton*)sender {
    sender.selected = !sender.selected;
    self.slideMenuController.showRightMenuInLandscape = sender.selected;
}

@end
