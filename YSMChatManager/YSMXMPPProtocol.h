//
//  YSMXMPPProtocol.h
//  即时通讯
//
//  Created by 忆思梦 on 2016/10/30.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark 登录注册
@protocol YSMXMPPLoginDelegate <NSObject>
@optional
//登录&注册回调
- (void)loginCallBack:(BOOL)success withError:(DDXMLElement *)error;
- (void)registerCallBack:(BOOL)success withError:(DDXMLElement *)error;
@end


#pragma mark 好友
@protocol YSMXMPPRosterDelegate <NSObject>
/**
 好友加载完成
 */
- (void)rosterDidEndPopulating;

@optional
/**
 好友申请
 
 @param presence 申请人
 
 @return 是否同意
 */
- (BOOL)shouldAcceptPresenceSubscription:(XMPPPresence *)presence;
@end


#pragma mark 消息
@protocol YSMXMPPMessageDelegate <NSObject>
@optional
/**
 收到消息
 */
- (void)didReceiveMessage;
/**
 消息已发送
 */
- (void)messageDidSend;

- (void)finishedLoadMessage;

@end
