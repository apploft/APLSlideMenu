//
//  APLMenuViewController.m
//  APLSlideMenuDemo
//
//  Created by Tobias Conradi on 18.12.12.
//  Copyright (c) 2012 apploft GmbH. All rights reserved.
//

#import "APLMenuViewController.h"
#import "APLSlideMenuViewController.h"
#import "APLViewController.h"

@interface APLMenuViewController ()
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@end

@implementation APLMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:self.currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView selectRowAtIndexPath:self.currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:@"aCell"];
    aCell.textLabel.text = [NSString stringWithFormat:@"Menu %d",indexPath.row];
    return aCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentIndexPath = indexPath;
    id contentViewController = self.slideMenuController.contentViewController;
    if ([contentViewController isKindOfClass:[APLViewController class]]) {
        [(APLViewController*) contentViewController textLabel].text = [NSString stringWithFormat:@"Content %d",indexPath.row];
        [self.slideMenuController hideMenu:YES];
    }
}

@end
