//
//  RosterTableViewController.m
//  即时通讯
//
//  Created by 忆思梦 on 2016/10/30.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import "RosterTableViewController.h"
#import "ChatroomTableViewController.h"
#import "YSMRosterManager.h"
@interface RosterTableViewController ()<YSMXMPPRosterDelegate>

@property (nonatomic, strong) YSMRosterManager *rosterManager;

@end

@implementation RosterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtomItemAction:)];
    self.tableView.tableFooterView = [[UITableViewHeaderFooterView alloc] init];
    
    self.rosterManager = [[YSMRosterManager alloc] init];
    self.rosterManager.delegate = self;
    [self.rosterManager activateRoster];
}

- (void)rightBarButtomItemAction:(UIBarButtonItem *)sender{
    [self.rosterManager subscribePresenceAccount:@"user2"];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rosterManager.rosterJids.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rostercellId" forIndexPath:indexPath];
    XMPPUserCoreDataStorageObject * user = [self.rosterManager.rosterJids objectAtIndex:indexPath.row];
    cell.textLabel.text = user.displayName;
    //XMPPJID * jid = [self.rosterManager.rosterJids objectAtIndex:indexPath.row];
    //cell.textLabel.text = jid.user;
    return cell;
}

- (void)rosterDidEndPopulating{
    [self.tableView reloadData];
}
- (void)receivePresenceSubscription:(XMPPPresence *)presence handleComplete:(void (^)(BOOL))complete{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"好友申请" message:[NSString stringWithFormat:@"%@请求添加您为好友",presence.fromStr] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * acceptAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        complete(YES);
    }];
    UIAlertAction * rejectAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        complete(NO);
    }];
    [alert addAction:acceptAction];
    [alert addAction:rejectAction];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
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
    XMPPUserCoreDataStorageObject * chater = [self.rosterManager.rosterJids objectAtIndex:index];
    ChatroomTableViewController * chatVC = segue.destinationViewController;
    chatVC.chater = chater;
}

@end
