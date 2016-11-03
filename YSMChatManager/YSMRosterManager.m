//
//  YSMRosterManager.m
//  即时通讯
//
//  Created by 忆思梦 on 2016/11/2.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import "YSMRosterManager.h"

@interface YSMRosterManager ()
/**
 好友列表
 */
@property (nonatomic, strong) NSMutableArray *rosterJids;

@end

@implementation YSMRosterManager
#pragma mark - 好友

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
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldAcceptPresenceSubscription:)]) {
        if ([self.delegate shouldAcceptPresenceSubscription:presence]) {
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
    NSLog(@"好友列表  %@",self.rosterJids);
    if (self.delegate && [self.delegate respondsToSelector:@selector(rosterDidEndPopulating)]) {
        [self.delegate rosterDidEndPopulating];
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
@end
