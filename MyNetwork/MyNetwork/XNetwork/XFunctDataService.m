//
//  XFunctDataService.m
//  MyNetwork
//
//  Created by YD_iOS on 2017/2/24.
//  Copyright © 2017年 Eonman. All rights reserved.
//

#import "XFunctDataService.h"

@interface XFunctDataService()<NSURLSessionDataDelegate>

@end

@implementation XFunctDataService

- (void)startGetRequest{
    // 1.delegateQueue参数表示协议方法将会在(NSOperationQueue)队列里面执行
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:[[NSOperationQueue alloc] init]];
    // 2.创建任务(因为要使用代理方法,就不需要block方式的初始化了)
    NSURL *url = [NSURL URLWithString:@"http://httpbin.org/get"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url]];
    // 3.执行任务
    [task resume];
}

- (void)startPostRequest{
    // 1.创建一个网络路径
    NSURL *url = [NSURL URLWithString:@"http://httpbin.org/post"];
    // 2.创建一个网络请求，分别设置请求方法、请求参数
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary *dict = @{@"key":@"value"};
    NSData *body = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:body
                                      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                          NSLog(@"-------%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
                                      }];
}

#pragma make Delegate
#pragma mark -- NSURLSessionDataDelegate
// 1.接收到服务器的响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    //此处需要允许处理服务器的响应，才会继续加载服务器的数据。
    //若在接收响应时需要对返回的参数进行处理(如获取响应头信息等),那么这些处理应该放在这个允许操作的前面
    completionHandler(NSURLSessionResponseAllow);
}
// 2.接收到服务器的数据（此方法在接收数据过程会多次调用）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // 处理每次接收的数据，例如每次拼接到自己创建的数据receiveData
    NSLog(@"%@",[self dataToDictionary:data]);
}
// 3.3.任务完成时调用（如果成功，error == nil）
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(error != nil){
        NSLog(@"请求失败:%@",error);
    }
}

-(id)dataToDictionary:(NSData *)data
{
    NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //datastring = [datastring deleteSpecialCode];//过滤特殊字符
    datastring = [datastring stringByReplacingOccurrencesOfString:@"\"id\":" withString:@"\"modelId\":"];
    
    NSData *dataString = [datastring dataUsingEncoding:NSUTF8StringEncoding];
    id result = [NSJSONSerialization JSONObjectWithData:dataString options:NSJSONReadingMutableContainers error:nil];
    
    return result;
}


@end
