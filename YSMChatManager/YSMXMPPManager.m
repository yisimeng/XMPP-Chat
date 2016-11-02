//
//  YSMChatManager.m
//  即时通讯
//
//  Created by 忆思梦 on 2016/10/29.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import "YSMXMPPManager.h"

typedef NS_ENUM(NSInteger,ConnectToServerType){
    ConnectToServerLogin, //登录
    ConnectToServerReg    //注册
};

@interface YSMXMPPManager ()<XMPPStreamDelegate,XMPPRosterDelegate,NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) ConnectToServerType connectToServerType;
/**
 好友列表
 */
@property (nonatomic, strong) NSMutableArray *rosterJids;

@property (nonatomic, strong) NSMutableArray *messageArray;

@property (nonatomic, strong) NSFetchedResultsController * fetchController;
@end

@implementation YSMXMPPManager

+ (YSMXMPPManager *)shareManager{
    static YSMXMPPManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YSMXMPPManager alloc] init];
    });
    return manager;
}
- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

- (XMPPStream *)xmppStream{
    if (_xmppStream == nil) {
        _xmppStream = [[XMPPStream alloc] init];
        //设置ip、端口、心跳时间、允许后台运行
        _xmppStream.hostName = kHostName;
        _xmppStream.hostPort = kHostPort;
        _xmppStream.keepAliveInterval = 30;
        _xmppStream.enableBackgroundingOnSocket = YES;
        //设置代理，接收回调
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _xmppStream;
}

//设置用户jid
- (void)configConnectServerStreamJid{
    //用户，域名，resource：设备
    XMPPJID * jid = [XMPPJID jidWithUser:self.account domain:kDomin resource:kResource];
    self.xmppStream.myJID = jid;
}

//连接服务器
- (void)connectToServer{
    //判断是否连接，如果连接先断开连接
    if (self.xmppStream.isConnected) {
        [self disconnectWithServer];
    }
    NSError *err = nil;
    if(![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]){
        NSLog(@"连接服务器失败：%@",err);
    }
}
- (void)disconnectWithServer{
    //获取状态
    XMPPPresence * presence = [XMPPPresence presenceWithType:@"unavailable"];
    //改变当前用户状态
    [self.xmppStream sendElement:presence];
    //断开连接
    [self.xmppStream disconnect];
}

#pragma mark - 连接服务器回调
//连接服务器成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSError *error = nil;
    switch (_connectToServerType) {
        case ConnectToServerLogin:
            //验证密码登录
            if (![sender authenticateWithPassword:_password error:&error]) {
                NSLog(@"登录失败：%@",error);
            }
            break;
        case ConnectToServerReg:
            //注册账号密码
            if (![sender registerWithPassword:_password error:&error]) {
                NSLog(@"注册失败：%@",error);
            }
            break;
        default:
            break;
    }
}
//服务器已关闭
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    NSLog(@"断开连接：%@",error);
}
//连接超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    
}

#pragma mark - 登录注册
- (void)loginWithAccount:(NSString *)account password:(NSString *)password{
    self.account = account;
    self.password = password;
    self.connectToServerType = ConnectToServerLogin;
    [self configConnectServerStreamJid];
    [self connectToServer];
}

- (void)regisgerWithAccount:(NSString *)account password:(NSString *)password{
    self.account = account;
    self.password = password;
    self.connectToServerType = ConnectToServerReg;
    [self configConnectServerStreamJid];
    [self connectToServer];
}
- (void)logout{
    [self disconnectWithServer];
    self.password = @"";
    self.account = @"";
}

//登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    //改变登录状态
    XMPPPresence * presence = [XMPPPresence presenceWithType:@"available"];
    [sender sendElement:presence];
    if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(loginCallBack:withError:)]) {
        [self.loginDelegate loginCallBack:YES withError:nil];
    }
}
//登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(loginCallBack:withError:)]) {
        [self.loginDelegate loginCallBack:NO withError:error];
    }
}
//注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(registerCallBack:withError:)]) {
        [self.loginDelegate registerCallBack:YES withError:nil];
    }
}
//注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    if (self.loginDelegate && [self.loginDelegate respondsToSelector:@selector(registerCallBack:withError:)]) {
        [self.loginDelegate registerCallBack:NO withError:error];
    }
}

#pragma mark - 好友

- (void)activateRoster{
    //激活好友
    [self.xmppRoster activate:self.xmppStream];
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
        //设置代理
        [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _xmppRoster;
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
    if (self.rosterDelegate && [self.rosterDelegate respondsToSelector:@selector(shouldAcceptPresenceSubscription:)]) {
        if ([self.rosterDelegate shouldAcceptPresenceSubscription:presence]) {
            //同意好友申请，并添加对方为好友
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
        }else{
            //拒绝好友申请
            [self.xmppRoster rejectPresenceSubscriptionRequestFrom:presence.from];
        }
    }
}
//开始检索好友
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version{
    NSLog(@"开始获取好友列表");
}
//检索好友结束
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"获取好友列表结束");
    if (self.rosterDelegate && [self.rosterDelegate respondsToSelector:@selector(rosterDidEndPopulating)]) {
        [self.rosterDelegate rosterDidEndPopulating];
    }
}
//检索出好友，一次检索一个
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item{
    //先取出jid字符串
    NSString * jidStr = [[item attributeForName:@"jid"] stringValue];
    //通过jid字符串获取jid对象
    XMPPJID * jid = [XMPPJID jidWithString:jidStr];
    //去重
    if ([self.rosterJids containsObject:jid]) {
        return;
    }
    //用户是否存在
    if (jid.user) {
        [self.rosterJids addObject:jid];
    }
}



#pragma mark
- (void)activateMessage{
    //激活消息模块
    [self.messageArchving activate:self.xmppStream];
}
- (XMPPMessageArchiving *)messageArchving{
    if (_messageArchving == nil) {
        //消息
        self.messageArray = [NSMutableArray arrayWithCapacity:1];
        //初始化消息仓库
        XMPPMessageArchivingCoreDataStorage * messageStroage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        //初始化消息归档对象
        _messageArchving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:messageStroage dispatchQueue:dispatch_get_main_queue()];
        //设置上下文
        self.messageContext = messageStroage.mainThreadManagedObjectContext;
    }
    return _messageArchving;
}
//接收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"收到了一条消息：%@",message);
    if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(didReceiveMessage)]) {
        [self.messageDelegate didReceiveMessage];
    }
}
//已发送消息
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    NSLog(@"已成功发送消息：%@",message);
    if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(messageDidSend)]) {
        [self.messageDelegate messageDidSend];
    }
}
#pragma mark 刷新消息的方法
-(void)reloadMessageWithChaterJid:(XMPPJID *)chaterJid{
    //得到上下文
    //创建搜索请求
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    //从上下文中获取归档消息的实体描述  EXP-0136:XMPPMessageArchiving_Message_CoreDataObject  实体名称
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:self.messageContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    //创建谓词，设置过滤条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@", self.xmppStream.myJID.bare,chaterJid.bare];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    //指定排序方式
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    //给索引设置排序方式
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.messageContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    _fetchController.delegate = self;
    [_fetchController performFetch:&error];
    if (error) {
        NSLog(@"搜索消息失败：%@",error);
    }
//    NSArray *fetchedObjects = [self.messageContext executeFetchRequest:fetchRequest error:&error];
//    if (fetchedObjects == nil) {
//        
//    }
    NSLog(@"搜索消息结果：%@",_fetchController.fetchedObjects);
    if (self.messageArray.count != 0) {
        [self.messageArray removeAllObjects];
    }
    self.messageArray = [NSMutableArray arrayWithArray:_fetchController.fetchedObjects];
    
    if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(finishedLoadMessage)]) {
        [self.messageDelegate finishedLoadMessage];
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath{
    if (type == NSFetchedResultsChangeInsert) {
        [self.messageArray addObject:anObject];
        if (self.messageDelegate && [self.messageDelegate respondsToSelector:@selector(finishedLoadMessage)]) {
            [self.messageDelegate finishedLoadMessage];
        }
    }
}


@end
