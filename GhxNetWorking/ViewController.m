//
//  ViewController.m
//  GhxNetWorking
//
//  Created by 郭海祥 on 2017/10/10.
//  Copyright © 2017年 ghx. All rights reserved.
//

#import "ViewController.h"
#import "NetWorkHelper.h"
#import "NetWorkTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self  initUI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- InitUI
- (void)initUI {
    //按钮
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 100, 50)];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 5;
    btn.layer.borderColor = [UIColor blackColor].CGColor;
    [btn setTitle:@"请求" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:btn];
}

#pragma mark- Event
- (void)btnClick {
    [NetWorkHelper currentNetStatus:^(BOOL isConnect, AFNetworkReachabilityStatus currentStatus) {
        NSLog(@"");
    }];
    
    //版本更新 通过 bundleid , so 不用修改什么配置
    //    [[NetWorkHelper sharedInstance] checkSystemIfNeedUpdate:^(BOOL isNeed, NSString *updateUrl, NSString *msg, NSDictionary *dic) {
    //        NSLog(@"");
    //    }];
    [[NetWorkHelper sharedInstance] checkSystemIfNeedUpdate:nil];
    
    
    //方法一 继承 Network 请求公共写在一个类
    //    NetWorkTool * netTool = [[NetWorkTool alloc] initWithSuccess:^(id obj) {
    //        NSLog(@"");
    //    } fail:^(id obj) {
    //        NSLog(@"");
    //
    //    }];
    //    [netTool login:@"五华社区" pwd:@"123456" isclassify:YES];
    
    //方法二  直接使用 降低耦合度
    //    NetWorkHelper * helper = [[NetWorkHelper alloc] init];
    //    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:1];
    //    [params setObject:@"五华社区" forKey:@"user"];
    //    [params setObject:[helper md5:@"123456"] forKey:@"password"];
    //    [params setObject:[NSString stringWithFormat:@"%d",1] forKey:@"isclassify"];
    //    [helper requestURLString:@"http://139.224.210.9:8023/WebApi/api/v2/public/login-and-getmenus" parameters:params httpRequestType:RequestPost succeed:^(id responseObject) {
    //
    //        NSLog(@"");
    //
    //    } failure:^(NSError *error) {
    //        
    //        NSLog(@"");
    //        
    //    }];
    
}


@end
