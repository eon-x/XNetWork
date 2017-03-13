//
//  ViewController.m
//  MyNetwork
//
//  Created by YD_iOS on 2017/2/23.
//  Copyright © 2017年 Eonman. All rights reserved.
//

#import "ViewController.h"
#import "XDataService.h"
#import "DViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark 点击其他地方收起键盘
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    DViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)asGetRequset:(id)sender {
    [XDataService startGetWithURL:@"http://httpbin.org/get" cBlock:^(id result) {
        NSLog(@"%@",result);
    } fBlock:^(id error) {
        NSLog(@"%@",error);
    }];
}
- (IBAction)asPostRequest:(id)sender {
    
    [XDataService startPostCacheWithURL:@"http://httpbin.org/post" dict:@{@"test":@"value3"} cBlock:^(id result) {
        NSLog(@"%@",result);
    } fBlock:^(id error) {
        NSLog(@"%@",error);
    }];
    
//    [XDataService startPostWithURL:@"http://httpbin.org/post" dict:@{@"test":@"value"} cBlock:^(id result) {
//        NSLog(@"%@",result);
//    } fBlock:^(id error) {
//        NSLog(@"%@",error);
//    }];
    
}
- (IBAction)sGetRequest:(id)sender {
    for (int i=0; i<3; i++) {
        [XDataService startSyncGetWithURL:@"http://httpbin.org/get" cBlock:^(id result) {
            NSLog(@"成功 time：%@",[NSDate new]);
        } fBlock:^(id error) {
            NSLog(@"fail time：%@",[NSDate new]);
        }];
    }
}
- (IBAction)sPostRequest:(id)sender {
    for (int i=0; i<3; i++) {
        
        [XDataService startSyncPostWithURL:@"http://httpbin.org/post" dict:@{@"test":@"value"} cBlock:^(id result) {
            NSLog(@"成功 time：%@",[NSDate new]);
        } fBlock:^(id error) {
            NSLog(@"fail time：%@",[NSDate new]);
        }];
    }
}


@end
