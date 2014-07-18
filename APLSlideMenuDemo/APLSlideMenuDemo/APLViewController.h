//
//  APLViewController.h
//  APLSlideMenuDemo
//
//  Created by Tobias Conradi on 18.12.12.
//  Copyright (c) 2012 apploft GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APLViewController : UIViewController

@property (nonatomic, assign) IBOutlet UILabel *textLabel;

- (IBAction)showLeftMenu:(id)sender;
- (IBAction)showRightMenu:(id)sender;
- (IBAction)gestureSupportChanged:(id)sender;

@end
