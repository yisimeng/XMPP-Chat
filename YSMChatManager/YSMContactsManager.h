//
//  YSMContactsManager.h
//  即时通讯
//
//  Created by 忆思梦 on 2016/11/2.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSMContactsManager : NSObject


+ (YSMContactsManager *)contactsManagerWithContactsJid:(XMPPJID *)contactsJid;

@property (nonatomic, assign) id<YSMXMPPContactsDelegate> contactsDelegate;

@property (nonatomic, readonly) XMPPJID *contactsJid;
/**
 归档message
 */
@property (nonatomic, strong) XMPPMessageArchiving *messageArchving;
/**
 消息列表
 */
@property (nonatomic, readonly) NSMutableArray *messageArray;
/**
 激活message模块
 */
- (void)activateMessage;



//-(void)reloadMessageWithChaterJid:(XMPPJID *)chaterJid;

@end
