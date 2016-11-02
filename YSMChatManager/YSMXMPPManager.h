//
//  YSMXMPPManager.h
//  即时通讯
//
//  Created by 忆思梦 on 2016/10/29.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSMXMPPProtocol.h"
#import <XMPPFramework/XMPPvCardTemp.h>
#import <XMPPFramework/XMPPvCardCoreDataStorage.h>
@interface YSMXMPPManager : NSObject
/**
 管理器

 @return <#return value description#>
 */
+ (YSMXMPPManager *)shareManager;
/**
 登录注册代理
 */
@property (nonatomic, weak) id<YSMXMPPLoginDelegate> loginDelegate;
/**
 通信管道
 */
@property (nonatomic, strong) XMPPStream *xmppStream;

@property (nonatomic, readonly) XMPPJID *myJid;

#pragma mark - 登录注册
/**
 用户登录

 @param account  <#account description#>
 @param password <#password description#>
 */
- (void)loginWithAccount:(NSString *)account password:(NSString *)password;
/**
 注册用户

 @param account  <#account description#>
 @param password <#password description#>
 */
- (void)regisgerWithAccount:(NSString *)account password:(NSString *)password;
/**
 退出登录
 */
- (void)logout;


#pragma mark - 好友
@property (nonatomic, strong) XMPPRoster *xmppRoster;
/**
 好友代理
 */
@property (nonatomic, weak) id<YSMXMPPRosterDelegate> rosterDelegate;
/**
 好友列表
 */
@property (nonatomic, readonly) NSMutableArray *rosterJids;
/**
 激活好友模块
 */
- (void)activateRoster;
/**
 添加好友

 @param account <#account description#>
 */
- (void)subscribePresenceAccount:(NSString *)account;
/**
 删除好友

 @param account <#account description#>
 */
- (void)unSubscribePresenceAccount:(NSString *)account;

#pragma mark - 电子名片
@property (nonatomic, strong) XMPPvCardCoreDataStorage *vCardStorage;
@property (nonatomic, strong) XMPPvCardTempModule *vCard;
@property (nonatomic, strong) XMPPvCardAvatarModule *avatar;

@end
