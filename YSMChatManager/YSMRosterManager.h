//
//  YSMRosterManager.h
//  即时通讯
//
//  Created by 忆思梦 on 2016/11/2.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSMRosterManager : NSObject

#pragma mark - 好友
@property (nonatomic, strong) XMPPRoster *xmppRoster;
/**
 好友代理
 */
@property (nonatomic, weak) id<YSMXMPPRosterDelegate> delegate;
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

@end
