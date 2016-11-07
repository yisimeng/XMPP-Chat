//
//  YSMRosterManager.m
//  即时通讯
//
//  Created by 忆思梦 on 2016/11/2.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import "YSMRosterManager.h"

@interface YSMRosterManager ()<NSFetchedResultsControllerDelegate>
/**
 好友列表
 */
@property (nonatomic, strong) NSMutableArray *rosterJids;
/**
 好友上下文
 */
@property (nonatomic, strong) NSManagedObjectContext *rosterContext;

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@end

@implementation YSMRosterManager

- (void)activateRoster{
    //激活好友
    [self.xmppRoster activate:[YSMXMPPManager shareManager].xmppStream];
    [[YSMXMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
- (XMPPRoster *)xmppRoster{
    if (_xmppRoster == nil) {
        //好友管理
        self.rosterJids = [NSMutableArray arrayWithCapacity:1];
        //获得一个存储好友的CoreData仓库，用来数据持久化
        XMPPRosterCoreDataStorage * rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        //初始化xmppRoster
        _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:rosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        _xmppRoster.autoFetchRoster = YES;
        self.rosterContext = rosterCoreDataStorage.mainThreadManagedObjectContext;
        //设置代理
        [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _xmppRoster;
}
- (NSFetchedResultsController *)fetchController{
    if (_fetchController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:self.rosterContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@", [YSMXMPPManager shareManager].myJid.bare];
        [fetchRequest setPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName"
                                                                       ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.rosterContext sectionNameKeyPath:nil cacheName:nil];
        _fetchController.delegate = self;
    }
    return _fetchController;
}

#pragma mark 好友管理
//留有疑问：subscribePresenceToUser  和add  的区别。一个是好友，一个是联系人？
- (void)subscribePresenceAccount:(NSString *)account{
    XMPPJID * jid = [XMPPJID jidWithUser:account domain:kDomin resource:kResource];
    [self.xmppRoster subscribePresenceToUser:jid];
}
- (void)unSubscribePresenceAccount:(NSString *)account{
    //需要先判断是否已经是好友
    XMPPJID * jid = [XMPPJID jidWithString:account];
    [self.xmppRoster removeUser:jid];
}
//好友关系的推送
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq{
    NSLog(@"roster 接受到push：%@",iq);
}

#pragma mark XMPPRosterDelegate 好友请求回调
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    if (self.delegate && [self.delegate respondsToSelector:@selector(receivePresenceSubscription:handleComplete:)]) {
        [self.delegate receivePresenceSubscription:presence handleComplete:^(BOOL accept) {
            if (accept) {
                //同意好友申请，并添加对方为好友
                [self.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
            }else{
                //拒绝好友申请
                [self.xmppRoster rejectPresenceSubscriptionRequestFrom:presence.from];
            }
        }];
    }
}
//开始检索好友
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version{
    NSLog(@"开始获取好友列表");
}
//检索好友结束
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"好友列表  %@",self.rosterJids);
    NSError *error = nil;
    //检索结束，并添加自动搜索索引，通知代理
    [self.fetchController performFetch:&error];
    if (error) {
        NSLog(@"搜索消息失败：%@",error);
    }
    self.rosterJids = [NSMutableArray arrayWithArray:self.fetchController.fetchedObjects];
}
//检索出好友，一次检索一个
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item{
    NSLog(@"检索出一个好友：%@",item);
}

#pragma mark NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath{
    //fetch结果，根据type，可执行操作有：insert/delete/move/update，后续补全
    //添加一个代理方法，参数为object、indexpath、newIndexpath、type.因为根据type的不同，列表页需要进行不同的刷新方法
    if (type == NSFetchedResultsChangeInsert) {
        if ([anObject isKindOfClass:[XMPPUserCoreDataStorageObject class]]) {
            [self.rosterJids addObject:anObject];
            if (self.delegate && [self.delegate respondsToSelector:@selector(rosterDidEndPopulating)]) {
                [self.delegate rosterDidEndPopulating];
            }
        }
    }else if (type == NSFetchedResultsChangeDelete){
        
    }else if (type == NSFetchedResultsChangeMove){
        
    }else if (type == NSFetchedResultsChangeUpdate){
        
    }
}
@end
