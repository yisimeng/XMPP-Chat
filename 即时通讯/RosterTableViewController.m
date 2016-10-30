//
//  RosterTableViewController.m
//  即时通讯
//
//  Created by 忆思梦 on 2016/10/30.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import "RosterTableViewController.h"

@interface RosterTableViewController ()<YSMXMPPRosterDelegate>

@end

@implementation RosterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtomItemAction:)];
    [YSMXMPPManager shareManager].rosterDelegate = self;
    self.tableView.tableFooterView = [[UITableViewHeaderFooterView alloc] init];
}

- (void)rightBarButtomItemAction:(UIBarButtonItem *)sender{
//    [[YSMXMPPManager shareManager] subscribePresenceAccount:@"user2"];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [YSMXMPPManager shareManager].rosterJids.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    XMPPJID * jid = [[YSMXMPPManager shareManager].rosterJids objectAtIndex:indexPath.row];
    cell.textLabel.text = jid.user;
    return cell;
}

- (void)rosterDidEndPopulating{
    [self.tableView reloadData];
}

@end
