//
//  XDBData.h
//  MyNetwork
//
//  Created by YD_iOS on 2017/3/13.
//  Copyright © 2017年 Eonman. All rights reserved.
//  数据缓存功能类 - 需要FMDB支持

#import <Foundation/Foundation.h>

@interface XDBData : NSObject

+ (instancetype)shareInstance;

///获取缓存数据
- (NSData *)getCacheDataWithURL:(NSString *)urlString dict:(NSDictionary *)dict;

///保存请求数据
- (void)saveDataWithData:(NSData *)data URL:(NSString *)urlString dict:(NSDictionary *)dict;

@end
