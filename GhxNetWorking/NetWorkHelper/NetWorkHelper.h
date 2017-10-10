//
//  NetWorkHelper.h
//  TestProject
//
//  Created by Guohx on 16/4/1.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFHTTPSessionManager.h>

/**
 *  块的执行,请求返回数据接收
 */
typedef void(^OperateReturnSuccess)(id obj); ///<请求成功
typedef void(^OperateReturnFail)(id obj); ///<请求失败

/**
 枚举请求类型
 */
typedef enum {
    RequestPost = 0,
    RequestGet
}NetWorkRequestType;



/**
 *  网络请求类 【网络请求，网络判断，app软件更新】
 */
@interface NetWorkHelper : NSObject
/**
 *  调用本类的类名称
 */
@property (nonatomic, weak) Class originalClass;
/**
 *  取消请求
 */
@property (nonatomic) BOOL cancelRequest;


#pragma mark- Prepare Method
/**
 *  实例化，网络请求对象
 *
 *  @return 实例对象
 */
+ (instancetype)sharedInstance;


/** [推荐使用这个方法]
 *  指定代理以及网络请求回传参数处理的方法
 *
 *  @param sucess 成功block
 *  @param fail   失败block //组要关闭 下拉 上拉刷新的提示
 *
 *  @return 当前对象
 */
- (id)initWithSuccess:(OperateReturnSuccess)sucess fail:(OperateReturnFail)fail;

- (void)loadRequestWithDomainUrl:(NSString *)domainUrl
                      methodName:(NSString *)methodName
                          params:(NSMutableDictionary *)params
                    postDataType:(NetWorkRequestType)postDataType;


#pragma mark- 请求返回处理可以通过 Block
/**
 无多媒体的请求
 
 @param URLString 地址字符串
 @param parameters 参数,可为空
 @param type 请求类型GET/POST
 @param succeedCallBack 成功回调
 @param failureCallBack 失败回调
 */
-(void)requestURLString:(NSString*)URLString parameters:(id)parameters httpRequestType:(NetWorkRequestType)type succeed:(void(^)(id responseObject))succeedCallBack failure:(void(^)(NSError *error))failureCallBack;




/**
 多媒体的请求
 
 @param URLString 地址字符串
 @param parameters 参数
 @param imgs 图片数组
 @param videos 视频数组
 @param fileName 服务器中的文件夹名字
 @param uploadPro 上传进度
 @param succeedCallBack 成功回调
 @param failureCallBack 失败回调
 */
-(void)requestURLString:(NSString*)URLString parameters:(id)parameters images:(NSArray*)imgs videos:(NSArray*)videos fileName:(NSString*)fileName uploadProgress:(void (^)(NSProgress * uploadPro))uploadPro succeed:(void(^)(id responseObject))succeedCallBack failure:(void(^)(NSError *error))failureCallBack;



/**
 取消当前的请求
 */
-(void)cancelCurrentRequest;

#pragma mark -



#pragma mark - 文件下载

/**
 下载文件
 
 @param URLString 文件地址
 @param uploadPro 下载进度
 @param completionHandler 完成回调
 */
-(void)downFileURLString:(NSString*)URLString uploadProgress:(void (^)(NSProgress * uploadPro))uploadPro completionHandler:(void (^)(NSURL *filePath,NSError *error))completionHandler;

/**
 暂停下载
 */
-(void)suspendDownloadTask;

/**
 继续下载
 */
-(void)restartDownloadTask;

/**
 取消下载
 */
-(void)cancelDownloadTask;



#pragma mark Request Method


#pragma mark- NetReachibility

/**
 获取网络连接状态
 
 @param statusCallBack 结果回调
 */
+(void)currentNetStatus:(void(^)(BOOL isConnect,AFNetworkReachabilityStatus currentStatus))statusCallBack;



/**
 检查当前是否有网络
 
 @return YES／NO
 */
+(BOOL)checkNetWork;


/**
 版本更新

 @param callBack 回调
 */
-(void)checkSystemIfNeedUpdate:(void (^)(BOOL isNeed, NSString * updateUrl, NSString * msg, NSDictionary * dic))callBack;


- (NSString *)md5:(NSString *)string;

@end
