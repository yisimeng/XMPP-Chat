//
//  ChatroomTableViewController.m
//  即时通讯
//
//  Created by 忆思梦 on 2016/10/31.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import "ChatroomTableViewController.h"
#import "YSMContactsManager.h"
@interface ChatroomTableViewController ()<YSMXMPPContactsDelegate>

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) YSMContactsManager *contactsManager;

@end

@implementation ChatroomTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messages = [NSMutableArray arrayWithCapacity:1];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtomItemAction:)];
    self.tableView.tableFooterView = [[UITableViewHeaderFooterView alloc] init];
    
    self.contactsManager = [YSMContactsManager contactsManagerWithContactsJid:self.chaterJid];
    self.contactsManager.contactsDelegate = self;
    [self.contactsManager activateMessage];
}

- (void)rightBarButtomItemAction:(UIBarButtonItem *)sender{
    XMPPMessage * message = [XMPPMessage messageWithType:@"chat" to:self.chaterJid];
    [message addBody:[NSString stringWithFormat:@"我是%@",[YSMXMPPManager shareManager].xmppStream.myJID.user]];
    [[YSMXMPPManager shareManager].xmppStream sendElement:message];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactsManager.messageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatroomCellId" forIndexPath:indexPath];
    XMPPMessageArchiving_Message_CoreDataObject * message = [self.contactsManager.messageArray objectAtIndex:indexPath.row];
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    if (message.isOutgoing) {
        cell.detailTextLabel.text = message.body;
    }else{
        cell.textLabel.text = message.body;
    }
    
    
    return cell;
}

- (void)finishedLoadMessage{
    NSLog(@"聊天页  消息加载完成");
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
