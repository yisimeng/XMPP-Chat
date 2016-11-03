//
//  YSMContactsManager.m
//  即时通讯
//
//  Created by 忆思梦 on 2016/11/2.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import "YSMContactsManager.h"

@interface YSMContactsManager ()<XMPPStreamDelegate,NSFetchedResultsControllerDelegate>
/**
 联系人Jid
 */
@property (nonatomic, strong) XMPPJID *contactsJid;
/**
 消息数组
 */
@property (nonatomic, strong) NSMutableArray *messageArray;

/**
 消息上下文
 */
@property (nonatomic, strong) NSManagedObjectContext *messageContext;
/**
 索引控制器，监听数据库
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@end

@implementation YSMContactsManager

+ (YSMContactsManager *)contactsManagerWithContactsJid:(XMPPJID *)contactsJid{
    YSMContactsManager * manager = [[YSMContactsManager alloc] init];
    manager.contactsJid = contactsJid;
    return manager;
}
- (XMPPMessageArchiving *)messageArchving{
    if (_messageArchving == nil) {
        //消息
        self.messageArray = [NSMutableArray arrayWithCapacity:1];
        //初始化消息仓库，如果是有多张表的话，存放需要多个文件，否则查询的数据会错误。sharedInstance:这个适用于只存一个表
        XMPPMessageArchivingCoreDataStorage * messageStroage = [[XMPPMessageArchivingCoreDataStorage alloc] initWithDatabaseFilename:self.contactsJid.user storeOptions:nil];
        //初始化消息归档对象
        _messageArchving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:messageStroage dispatchQueue:dispatch_get_main_queue()];
        //设置上下文
        self.messageContext = messageStroage.mainThreadManagedObjectContext;
    }
    return _messageArchving;
}

- (NSFetchedResultsController *)fetchController{
    if (_fetchController == nil) {
        //得到上下文
        //创建搜索请求
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
        //从上下文中获取归档消息的实体描述  EXP-0136:XMPPMessageArchiving_Message_CoreDataObject  实体名称
        NSEntityDescription * entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:self.messageContext];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        //创建谓词，设置过滤条件
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@&&bareJidStr=%@", [YSMXMPPManager shareManager].myJid.bare,self.contactsJid.bare];
        [fetchRequest setPredicate:predicate];
        // Specify how the fetched objects should be sorted
        //指定排序方式
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                ascending:YES];
        //给索引设置排序方式
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.messageContext sectionNameKeyPath:nil cacheName:@"Message"];
        
        _fetchController.delegate = self;
    }
    return _fetchController;
}

#pragma mark
- (void)activateMessage{
    //激活消息归档
    [self.messageArchving activate:[YSMXMPPManager shareManager].xmppStream];
    //添加stream代理，收发消息的代理
    [[YSMXMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    //启动自动索引
    [self.fetchController performFetch:&error];
    if (error) {
        NSLog(@"搜索消息失败：%@",error);
    }
    self.messageArray = [NSMutableArray arrayWithArray:self.fetchController.fetchedObjects];
}
//接收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"收到了一条消息：%@",message);
}
//已发送消息
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    NSLog(@"已成功发送消息：%@",message);
}
#pragma mark NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath{
    //fetch结果，根据type，可执行操作有：insert/delete/move/update，后续补全
    if (type == NSFetchedResultsChangeInsert) {
        [self.messageArray addObject:anObject];
        if (self.contactsDelegate && [self.contactsDelegate respondsToSelector:@selector(finishedLoadMessage)]) {
            [self.contactsDelegate finishedLoadMessage];
        }
    }else if (type == NSFetchedResultsChangeDelete){
        
    }else if (type == NSFetchedResultsChangeMove){
        
    }else if (type == NSFetchedResultsChangeUpdate){
        
    }
}

- (void)dealloc{
    //静默消息归档对象，required,否则下次再创建时会崩溃。
    [self.messageArchving deactivate];
}

@end
