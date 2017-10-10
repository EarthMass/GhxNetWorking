//
//  NetWorkHelper.m
//  TestProject
//
//  Created by Guohx on 16/4/1.
//
//

#import "NetWorkHelper.h"
#import <CommonCrypto/CommonDigest.h> //md5加密使用
#import <objc/runtime.h> ///<获取 调用 类

@interface NetWorkHelper() {
    // 下载句柄
    NSURLSessionDownloadTask *downloadTask;
}
@property(nonatomic,strong)AFHTTPSessionManager *manager;
@property(nonatomic,strong)NSURLSessionDataTask *task;
/**
 *  block 处理请求返回数据
 */
@property (nonatomic, copy) OperateReturnSuccess successBlock;
@property (nonatomic, copy) OperateReturnFail failBlock;

@end

@implementation NetWorkHelper

@synthesize originalClass;
@synthesize cancelRequest;

#pragma mark- 网络请求
#pragma mark-
///**
// *  实例化，网络请求对象
// *
// *  @return 实例对象
// */
+ (instancetype)sharedInstance {
//    static NetWorkHelper * client = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        client = [[NetWorkHelper alloc] init];
//    });
//    return client;
    return [[NetWorkHelper alloc] init];
}

#pragma mark 继承使用 统一的网络请求类处理请求声明
/**
 *  指定代理以及网络请求回传参数处理的方法
 *
 *  @param sucess 成功block
 *  @param fail   失败block
 *
 *  @return 当前对象
 */
- (id)initWithSuccess:(OperateReturnSuccess)sucess fail:(OperateReturnFail)fail {
    
    if (self = [super init]) {
        
        self.originalClass = object_getClass(sucess);
        self.successBlock = sucess;
        self.failBlock = fail;
        
    }
    return self;
}

- (void)setCancelRequest:(BOOL)cancelRequest {
    self.originalClass = nil;
    self.successBlock = nil;
    self.failBlock  = nil;
}
/**
 请求接口

 @param methodName 接口描述
 @param params 参数列表
 @param postDataType 请求类型Post Get 【default POSt】
 */
- (void)loadRequestWithDomainUrl:(NSString *)domainUrl
                      methodName:(NSString *)methodName
                          params:(NSMutableDictionary *)params
                    postDataType:(NetWorkRequestType)postDataType
{
    //判断网络
    /******/
    if (![self checkNetWorkPrivate]) {
        NSLog(@"没有网络");
    }
    
    
    _manager = [AFHTTPSessionManager manager];
    
    //设置相应内容类型
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json",@"text/javascript", nil];
    
    _manager.operationQueue.maxConcurrentOperationCount = 10;
    // 设置超时时间
    [_manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    _manager.requestSerializer.timeoutInterval = 10.0f;
    [_manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    NSString * requestUrl = nil;
    if (methodName) {
        requestUrl= [NSString stringWithFormat:@"%@%@",domainUrl,methodName];
    } else {
        requestUrl= [NSString stringWithFormat:@"%@",domainUrl];
    }

    
    if (postDataType == RequestPost && postDataType == 0) {
    
        [_manager POST:requestUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            if (self.successBlock) {
                self.successBlock(responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[_manager operationQueue] cancelAllOperations];

            if (self.failBlock) {
                self.failBlock(error);
            }
            
        }];

        
    } else {
        
        [_manager GET:requestUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (self.successBlock) {
                self.successBlock(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [[_manager operationQueue] cancelAllOperations];
            if (self.failBlock) {
                self.failBlock(error);
            }
        }];
        
    }
    
}
#pragma mark ***************************************
#pragma mark  每个请求独立，耦合低 begin
#pragma mark  不带多媒体的请求
-(void)requestURLString:(NSString *)URLString parameters:(id)parameters httpRequestType:(NetWorkRequestType)type succeed:(void (^)(id))succeedCallBack failure:(void (^)(NSError *))failureCallBack{
    
    //判断网络
    if (![self checkNetWorkPrivate]) {
        NSLog(@"没有网络");
    }
    
    //如果没有地址则return
    if (!URLString||[URLString isEqualToString:@""]) {
        return;
    }
    //地址进行UTF8转换，因为地址中可能包含中文
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9) {
        NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:URLString] invertedSet];
         URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
        
    }
    
    //创建网络请求管理对象
    _manager = [AFHTTPSessionManager manager];
    //声明请求的数据类型是json类型
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //请求超时时间
    _manager.requestSerializer.timeoutInterval = 20;
    //同一时间接受的请求数量
    _manager.operationQueue.maxConcurrentOperationCount = 10;
    //声明返回的结果类型为json类型
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //如果接受类型不一致时，替换为text／html等类型
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json",@"text/javascript", nil];
    switch (type) {
        case RequestGet:
        {
            _task = [_manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (succeedCallBack) {
                    succeedCallBack(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureCallBack) {
                    failureCallBack(error);
                }
            }];
        }
            break;
        case RequestPost:
        {
            _task = [_manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (succeedCallBack) {
                    succeedCallBack(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureCallBack) {
                    failureCallBack(error);
                }
            }];
        }
            break;
            
        default:
            break;
    }
    
    
}



#pragma mark  带多媒体的请求
-(void)requestURLString:(NSString *)URLString parameters:(id)parameters images:(NSArray *)imgs videos:(NSArray *)videos fileName:(NSString *)fileName uploadProgress:(void (^)(NSProgress *))uploadPro succeed:(void (^)(id))succeedCallBack failure:(void (^)(NSError *))failureCallBack{
    
    //判断网络
    /******/
    if (![self checkNetWorkPrivate]) {
        NSLog(@"没有网络");
    }
    
    //如果没有地址则return
    if (!URLString||[URLString isEqualToString:@""]) {
        return;
    }
    //地址进行UTF8转换，因为地址中可能包含中文
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9) {
        NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:URLString] invertedSet];
        URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
    }
    
    //创建网络请求管理对象
    _manager = [AFHTTPSessionManager manager];
    //声明请求的数据类型是json类型
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //请求超时时间
    _manager.requestSerializer.timeoutInterval = 20;
    //同一时间接受的请求数量
    _manager.operationQueue.maxConcurrentOperationCount = 10;
    //声明返回的结果类型为json类型
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //如果接受类型不一致时，替换为text／html等类型
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json",@"text/javascript", nil];
    
    _task = [_manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //处理图片
        if (imgs&&imgs.count) {
            for (UIImage *image in imgs) {
                NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
                NSString *dateString = [format stringFromDate:[NSDate date]];
                NSString *imgName = [NSString stringWithFormat:@"%@.jpg",dateString];
                //将数据拼接起来
                [formData appendPartWithFileData:imgData name:fileName fileName:imgName mimeType:@"image/jpeg"];
            }
        }
        //处理视频
        if (videos&&videos.count) {
            for (NSData *data in videos) {
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
                NSString *dateString = [format stringFromDate:[NSDate date]];
                NSString *videoName = [NSString stringWithFormat:@"%@.MOV",dateString];
                //将数据拼接起来
                [formData appendPartWithFileData:data name:fileName fileName:videoName mimeType:@"media"];
            }
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (uploadProgress) {
            uploadPro(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (succeedCallBack) {
            succeedCallBack(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureCallBack) {
            failureCallBack(error);
        }
    }];
    
}


#pragma mark  取消当前的请求
-(void)cancelCurrentRequest{
    [_task cancel];
}



#pragma mark - 下载文件
#pragma mark -
-(void)downFileURLString:(NSString *)URLString uploadProgress:(void (^)(NSProgress *))uploadPro completionHandler:(void (^)(NSURL *, NSError *))completionHandler{
    
    //判断网络
    if (![self checkNetWorkPrivate]) {
        NSLog(@"没有网络");
        return;
    }
    
    //如果没有地址则return
    if (!URLString||[URLString isEqualToString:@""]) {
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //下载Task操作
    downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (uploadPro) {
            NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
            uploadPro(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //返回文件的位置的路径URL
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(filePath,error);
        }
    }];
    [downloadTask resume];
    
}
#pragma mark  暂停下载
-(void)suspendDownloadTask{
    [downloadTask suspend];
}
#pragma mark  继续下载
-(void)restartDownloadTask{
    [downloadTask resume];
}
#pragma mark 取消下载
-(void)cancelDownloadTask{
    [downloadTask cancel];
}
#pragma mark -

#pragma mark - 判断网络状态
+(void)currentNetStatus:(void (^)(BOOL, AFNetworkReachabilityStatus))statusCallBack{
    __block BOOL isConnect = YES;
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //开始监控
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                isConnect = NO;
            }
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
            {
                isConnect = NO;
            }
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                isConnect = YES;
            }
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                isConnect = YES;
            }
                break;
                
            default:
                break;
        }
        statusCallBack(isConnect,status);
    }];
}

#pragma mark 检查当前是否有网络
+(BOOL)checkNetWork{
    //不能掉用实例方法
    //    [self checkNetWorkPrivate];
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability =
    SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags =
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL isNetworkEnable  =(isReachable && !needsConnection) ? YES : NO;
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [UIApplication sharedApplication].networkActivityIndicatorVisible =isNetworkEnable;/*  网络指示器的状态： 有网络 ： 开  没有网络： 关  */
    //    });
    return isNetworkEnable;
}

#pragma makr 私有方法
-(BOOL)checkNetWorkPrivate{
    return [[self class] checkNetWork];
}





#pragma mark- 软件更新


#pragma mark - //类方法调用不了其他的实例方法
-(void)checkSystemIfNeedUpdate:(void (^)(BOOL isNeed, NSString * updateUrl, NSString * msg, NSDictionary * dic))callBack{
    //获取本地应用信息
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdetifierString = [infoDict objectForKey:@"CFBundleIdentifier"];
    bundleIdetifierString = [bundleIdetifierString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* urlString = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?bundleId=%@", bundleIdetifierString];
    
    
    [self requestURLString:urlString parameters:nil httpRequestType:RequestGet succeed:^(id responseObject) {
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            return ;
        }
        
        NSArray *resArray = [responseObject objectForKey:@"results"];
        
        if (resArray.count) {
            
            NSDictionary *resDict = [resArray firstObject];
            NSString* releaseNoteString = [resDict objectForKey:@"releaseNotes"];
            //appStore上版本
            NSString* newVersionString = [resDict objectForKey:@"version"];
            
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            //本地版本
            NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
            //更新地址
            NSString *applicationUrlString = [resDict objectForKey:@"trackViewUrl"];
            if([newVersionString compare:currentVersion options:NSNumericSearch] == NSOrderedDescending)
            {
                //        self.av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"新版本号%@", newVersionString]
                //                                                     message:[NSString stringWithFormat:@"%@", releaseNoteString]
                //                                                    delegate:self
                //                                           cancelButtonTitle:@"前往更新" otherButtonTitles:@"以后再说" ,nil];
                //        [self.av show];
                
                //可以将查询结果回调或者直接处理
                if (callBack) {//如果有需要block
                    callBack(YES,applicationUrlString,releaseNoteString,resDict);
                }
                else{
                    //NSObject的子类上使用delegate在ARC模式下是访问不到的，因为show完之后就被释放掉了
                    //这里使用另一种思路
                    UIViewController *viewC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"新版本号%@", newVersionString] message:[NSString stringWithFormat:@"%@", releaseNoteString] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *sureAcion = [UIAlertAction actionWithTitle:@"前往更新" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        
                        UIApplication *application = [UIApplication sharedApplication];
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 10) {
                            [application openURL:[NSURL URLWithString:applicationUrlString] options:@{} completionHandler:nil];
                        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
                           [application openURL:[NSURL URLWithString:applicationUrlString]];
#pragma clang diagnostic pop
                        }
                    } ];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"以后再说" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:cancelAction];
                    [alertController addAction:sureAcion];
                    [viewC presentViewController:alertController animated:YES completion:nil];
                }
            }
            else{
                //不需要更新
                if (callBack) {
                    callBack(NO,nil,nil,nil);
                }
            }
        }
        else{
            if (callBack) {
                callBack(NO,nil,@"AppStore未找到该应用信息",nil);
            }
            
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
    
}



#pragma mark-
#pragma mark- 数据处理
#pragma mark dic转String json->model
//字典转换为字符串
- (NSString*)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}
/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark  md5加密
/**
 *  md5加密
 *
 *  @return 加密后的字符串
 */
- (NSString *)md5:(NSString *)string {
    const char * cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (uint32_t)strlen(cStr), result); // This is the md5 call
    return [[NSString stringWithFormat:
             @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}





@end
