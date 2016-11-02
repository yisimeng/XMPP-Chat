//
//  RosterTableViewController.m
//  即时通讯
//
//  Created by 忆思梦 on 2016/10/30.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import "RosterTableViewController.h"
#import "ChatroomTableViewController.h"

@interface RosterTableViewController ()<YSMXMPPRosterDelegate>

@end

@implementation RosterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtomItemAction:)];
    [YSMXMPPManager shareManager].rosterDelegate = self;
    [[YSMXMPPManager shareManager] activateRoster];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rostercellId" forIndexPath:indexPath];
    XMPPJID * jid = [[YSMXMPPManager shareManager].rosterJids objectAtIndex:indexPath.row];
    cell.textLabel.text = jid.user;
    return cell;
}

- (void)rosterDidEndPopulating{
    [self.tableView reloadData];
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSInteger index = [self.tableView indexPathForCell:sender].row;
    XMPPJID * JID = [[YSMXMPPManager shareManager].rosterJids objectAtIndex:index];
    ChatroomTableViewController * chatVC = segue.destinationViewController;
    chatVC.chaterJid = JID;
}

@end
