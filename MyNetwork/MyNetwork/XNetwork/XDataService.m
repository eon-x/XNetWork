//
//  XDataService.m
//  MyNetwork
//
//  Created by YD_iOS on 2017/2/23.
//  Copyright © 2017年 Eonman. All rights reserved.
//

#import "XDataService.h"
#import "XDBData.h"

@implementation XDataService

#pragma mark 异步Get
+ (void)startGetWithURL:(NSString *)urlString cBlock:(Completion)cblock fBlock:(FailBlock)fblock{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            cblock([XDataService dataToDictionary:data]);
        }else
            fblock(error);
    }];
    [sessionDataTask resume];
}

#pragma mark 异步Post
+ (void)startPostWithURL:(NSString *)urlString dict:(NSDictionary *)dict cBlock:(Completion)cblock fBlock:(FailBlock)fblock{
    [XDataService postWithURL:urlString dict:dict cBlock:cblock fBlock:fblock isCache:NO];
}

#pragma mark 异步Post + Cache
+ (void)startPostCacheWithURL:(NSString *)urlString dict:(NSDictionary *)dict cBlock:(Completion)cblock fBlock:(FailBlock)fblock{

    //数据库中取出来的数据
    NSData *data = [[XDBData shareInstance] getCacheDataWithURL:urlString dict:dict];
    if (data) {
        cblock([XDataService dataToDictionary:data]);
    }else{
        [XDataService postWithURL:urlString dict:dict cBlock:cblock fBlock:fblock isCache:YES];
    }
}


+ (void)postWithURL:(NSString *)urlString dict:(NSDictionary *)dict cBlock:(Completion)cblock fBlock:(FailBlock)fblock isCache:(BOOL)isCache{
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    request.HTTPBody = jsonData;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            if (isCache) {
                //缓存数据
                [[XDBData shareInstance] saveDataWithData:data URL:urlString dict:dict];
            }
            cblock([XDataService dataToDictionary:data]);
        }else
            fblock(error);
    }];
    [sessionDataTask resume];
}

#pragma mark 同步Get
+ (void)startSyncGetWithURL:(NSString *)urlString cBlock:(Completion)cblock fBlock:(FailBlock)fblock{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            cblock([XDataService dataToDictionary:data]);
        }else
            fblock(error);
        
        dispatch_semaphore_signal(semaphore);   //发送信号

    }];
    [sessionDataTask resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
}

#pragma mark 同步Post
+ (void)startSyncPostWithURL:(NSString *)urlString dict:(NSDictionary *)dict cBlock:(Completion)cblock fBlock:(FailBlock)fblock{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    request.HTTPBody = jsonData;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            cblock([XDataService dataToDictionary:data]);
        }else
            fblock(error);
        
        dispatch_semaphore_signal(semaphore);   //发送信号

    }];
    [sessionDataTask resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
}

#pragma mark 把请求下来的数据解转成字典
+(id)dataToDictionary:(NSData *)data
{
    NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //datastring = [datastring deleteSpecialCode];//过滤特殊字符
    datastring = [datastring stringByReplacingOccurrencesOfString:@"\"id\":" withString:@"\"modelId\":"];
    
    NSData *dataString = [datastring dataUsingEncoding:NSUTF8StringEncoding];
    id result = [NSJSONSerialization JSONObjectWithData:dataString options:NSJSONReadingMutableContainers error:nil];
    
    return result;
}

@end
