//
//  XDataService.h
//  MyNetwork
//
//  Created by YD_iOS on 2017/2/23.
//  Copyright © 2017年 Eonman. All rights reserved.
//  如果不需要在请求中做处理，直接使用block的方式

#import <Foundation/Foundation.h>

typedef void (^Completion) (id result);
typedef void (^FailBlock) (id error);

@interface XDataService : NSObject

//异步
+ (void)startGetWithURL:(NSString *)urlString cBlock:(Completion)cblock fBlock:(FailBlock)fblock;
+ (void)startPostWithURL:(NSString *)urlString dict:(NSDictionary *)dict cBlock:(Completion)cblock fBlock:(FailBlock)fblock;

//异步获取缓存请求
+ (void)startPostCacheWithURL:(NSString *)urlString dict:(NSDictionary *)dict cBlock:(Completion)cblock fBlock:(FailBlock)fblock;

//同步
+ (void)startSyncGetWithURL:(NSString *)urlString cBlock:(Completion)cblock fBlock:(FailBlock)fblock;
+ (void)startSyncPostWithURL:(NSString *)urlString dict:(NSDictionary *)dict cBlock:(Completion)cblock fBlock:(FailBlock)fblock;

@end

//断点下载文件
//http://blog.csdn.net/majiakun1/article/details/38133789

//NSURLSession没有同步请求的方法，使用信号量解决；
//信号量是一个整型值并且具有一个初始计数值，并且支持两个操作：信号通知和等待。
//当一个信号量被信号通知，其计数会被增加。
//当一个线程在一个信号量上等待时，线程会被阻塞，直至计数器大于零，然后线程会减少这个计数。
//在GCD中有三个函数是semaphore的操作，分别是：
//dispatch_semaphore_create     创建一个semaphore
//dispatch_semaphore_signal     发送一个信号，信号量+1
//dispatch_semaphore_wait       等待信号，阻塞线程；小于等于0时
