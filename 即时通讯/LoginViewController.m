//
//  LoginViewController.m
//  即时通讯
//
//  Created by 忆思梦 on 2016/10/29.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<YSMXMPPLoginDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    [YSMXMPPManager shareManager].loginDelegate = self;
}

- (IBAction)loginAction:(id)sender {
    [[YSMXMPPManager shareManager] loginWithAccount:self.accountText.text password:self.passwordText.text];
}
- (IBAction)registerAction:(id)sender {
    [[YSMXMPPManager shareManager] regisgerWithAccount:self.accountText.text password:self.passwordText.text];
}

#pragma mark -- 登录注册回调
- (void)loginCallBack:(BOOL)success withError:(DDXMLElement *)error{
    if (success) {
//        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setBool:YES forKey:IsLogin];
//        [defaults synchronize];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)registerCallBack:(BOOL)success withError:(DDXMLElement *)error{
    NSLog(@"注册成功");
}
@end
