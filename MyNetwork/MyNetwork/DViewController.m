//
//  DViewController.m
//  MyNetwork
//
//  Created by YD_iOS on 2017/2/24.
//  Copyright © 2017年 Eonman. All rights reserved.
//

#import "DViewController.h"

@interface DViewController ()<NSURLSessionDataDelegate>

@end

@implementation DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)otherGetRequest:(id)sender {
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
- (IBAction)otherPostRequest:(id)sender {
    
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
- (IBAction)sOtherGetRequest:(id)sender {
}
- (IBAction)sOtherPostRequest:(id)sender {
}

- (void)downloadFile{
    // 1.创建网路路径
    NSURL *url = [NSURL URLWithString:@"http://172.16.2.254/php/phonelogin/image.png"] ;
    // 2.获取会话
    NSURLSession *session = [NSURLSession sharedSession];
    // 3.根据会话，创建任务
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        /*
         a.location是沙盒中tmp文件夹下的一个临时url,文件下载后会存到这个位置,由于tmp中的文件随时可能被删除,所以我们需要自己需要把下载的文件移动到其他地方:pathUrl.
         b.response.suggestedFilename是从相应中取出文件在服务器上存储路径的最后部分，例如根据本路径为，最后部分应该为：“image.png”
         */
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        NSURL *pathUrl = [NSURL fileURLWithPath:path];
        // 剪切文件
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:pathUrl error:nil];
    }];
    // 4.启动任务
    [task resume];
}

#pragma make Delegate
#pragma mark -- NSURLSessionDataDelegate// 1.接收到服务器的响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    //此处需要允许处理服务器的响应，才会继续加载服务器的数据。 若在接收响应时需要对返回的参数进行处理(如获取响应头信息等),那么这些处理应该放在这个允许操作的前面
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

#pragma mark -- 下载文件调用
// 1.每次写入调用(会调用多次)
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // 可在这里通过已写入的长度和总长度算出下载进度
    CGFloat progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite; NSLog(@"%f",progress);
}
// 2.下载完成时调用
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    //  这里的location也是一个临时路径,需要自己移动到需要的路径(caches下面)
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
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
