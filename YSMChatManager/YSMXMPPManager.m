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
@property (nonatomic, strong) XMPPJID *myJid;
/**
 好友列表
 */
@property (nonatomic, strong) NSMutableArray *rosterJids;

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
    self.myJid = jid;
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



@end
