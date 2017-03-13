//
//  XDBData.m
//  MyNetwork
//
//  Created by YD_iOS on 2017/3/13.
//  Copyright © 2017年 Eonman. All rights reserved.
//

#import "XDBData.h"
#import "FMDatabase.h"

@implementation XDBData

static FMDatabase *_dataDB;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static XDBData *dbData = nil;
    dispatch_once(&onceToken, ^{
        dbData = [[super allocWithZone:NULL]init];
    });
    
    NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/cachesData.db",NSHomeDirectory()];
    _dataDB = [FMDatabase databaseWithPath:path];
    [_dataDB open];
    [_dataDB executeUpdate:@"CREATE TABLE IF NOT EXISTS cItem (itemKey text NOT NULL, itemValue blob NOT NULL)"];
    
    return dbData;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [XDBData shareInstance];
}
- (instancetype)copyWithZone:(struct _NSZone *)zone{
    return [XDBData shareInstance];
}

- (NSData *)getCacheDataWithURL:(NSString *)urlString dict:(NSDictionary *)dict{

    NSString *cKey = [NSString stringWithFormat:@"%@%@",urlString, [self keyWithDict:dict]];
    FMResultSet *set = [_dataDB executeQuery:@"SELECT * FROM cItem where itemKey = ?",cKey];
    while ([set next]) {
        return [set objectForColumnName:@"itemValue"];
    }
    return nil;
}

- (void)saveDataWithData:(NSData *)data URL:(NSString *)urlString dict:(NSDictionary *)dict{
    
    NSString *cKey = [NSString stringWithFormat:@"%@%@",urlString, [self keyWithDict:dict]];
    [_dataDB executeUpdateWithFormat:@"INSERT INTO cItem (itemKey, itemValue) VALUES (%@, %@)",cKey, data];
}

- (NSString *)keyWithDict:(NSDictionary *)dict{
    
    NSArray *allKey = [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString *dicString = [[NSMutableString alloc] init];
    
    if (allKey.count > 0) {
        for (NSString *aKey in allKey) {
            [dicString appendFormat:@"&%@=%@",aKey, dict[aKey]];
        }
        
        NSString *nString = [dicString substringFromIndex:1];
        nString = [NSString stringWithFormat:@"?%@",nString];
        return nString;
        
    }else
        return @"";
}

@end
