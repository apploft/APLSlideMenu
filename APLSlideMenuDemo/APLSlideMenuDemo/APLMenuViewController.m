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

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:self.currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        self.tableView.contentInset = UIEdgeInsetsMake(20., 0., 0., 0.);
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView selectRowAtIndexPath:self.currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 12;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:@"aCell"];
    aCell.textLabel.text = [NSString stringWithFormat:@"Menu %ld",(long)indexPath.row];
    return aCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentIndexPath = indexPath;
    id contentViewController = self.slideMenuController.contentViewController;
    if ([contentViewController isKindOfClass:[APLViewController class]]) {
        [(APLViewController*) contentViewController textLabel].text = [NSString stringWithFormat:@"Content %ld",(long)indexPath.row];
        [self.slideMenuController hideMenu:YES];
    }
}

@end
