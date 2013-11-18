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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showMenu:(id)sender {
    [self.slideMenuController showMenu:YES];
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
@end
