//
//  NetWorkTool.h
//  DLEH
//
//  Created by 张勇 on 17/7/31.
//  Copyright © 2017年 ghx. All rights reserved.
//

#import "NetWorkHelper.h"

#define DOMAINURL @"http://url"

@interface NetWorkTool : NetWorkHelper

#pragma mark- 请求声明
/**
 *  用户登录
 */
- (void)login:(NSString *)user pwd:(NSString *)password isclassify:(BOOL)isclassify;


@end
