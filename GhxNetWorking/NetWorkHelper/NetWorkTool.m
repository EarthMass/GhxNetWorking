//
//  NetWorkTool.m
//  DLEH
//
//  Created by 张勇 on 17/7/31.
//  Copyright © 2017年 ghx. All rights reserved.
//

#import "NetWorkTool.h"

@implementation NetWorkTool

#pragma mark- 请求实现
- (void)login:(NSString *)user pwd:(NSString *)password isclassify:(BOOL)isclassify {
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:user forKey:@"user"];
    [params setObject:[self md5:password] forKey:@"password"];
    [params setObject:[NSString stringWithFormat:@"%d",isclassify] forKey:@"isclassify"];
    
    //发送请求
    [self loadRequestWithDomainUrl:DOMAINURL
                        methodName:@"/api/v2/public/login-and-getmenus"
                             params:params
                       postDataType:RequestPost];
    
}

@end
