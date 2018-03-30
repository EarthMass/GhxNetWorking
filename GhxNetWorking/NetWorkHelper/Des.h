//
//  Des.h
//  NetWorkTest
//
//  Created by 张勇 on 17/8/2.
//  Copyright © 2017年 ghx. All rights reserved.
//

#ifndef Des_h
#define Des_h

/*
 3.0+
 pod 'AFNetworking'
 
 
 NetWorkTool 集成自 NetWorkHelper
 NetWorkTool 中写接口
 使用 NetWorkTool
 
 pch 中添加
 #import "NetWorkTool.h"
 */
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:@"五华社区" forKey:@"user"];
    [params setObject:[helper md5:@"123456"] forKey:@"password"];
    [params setObject:[NSString stringWithFormat:@"%d",1] forKey:@"isclassify"];
    [helper requestURLString:@"url" parameters:params httpRequestType:RequestPost succeed:^(id responseObject) {

        NSLog(@"");

    } failure:^(NSError *error) {

        NSLog(@"");

    }];



/*
 使用
//网络判断
 [NetWorkHelper currentNetStatus:^(BOOL isConnect, AFNetworkReachabilityStatus currentStatus) {
 NSLog(@"");
 }];
 
 //版本更新 通过 bundleid , so 不用修改什么配置
 //    [[NetWorkHelper sharedInstance] checkSystemIfNeedUpdate:^(BOOL isNeed, NSString *updateUrl, NSString *msg, NSDictionary *dic) {
 //        NSLog(@"");
 //    }];
 
 //block方法可以 再处理 比如，强制更新等
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
 //    [helper requestURLString:@"url" parameters:params httpRequestType:RequestPost succeed:^(id responseObject) {
 //
 //        NSLog(@"");
 //
 //    } failure:^(NSError *error) {
 //
 //        NSLog(@"");
 //
 //    }];
 */
#endif /* Des_h */
