# XNetWork
网络请求框架

#### XDataService 类功能：实现同步或异步的Get、Post请求,使用方法如下
* 异步Get：

	```
	[XDataService startGetWithURL:@"http://httpbin.org/get" cBlock:^(id result) {
	        NSLog(@"%@",result);
	    } fBlock:^(id error) {
	        NSLog(@"%@",error);
	    }];
	
	```

* 异步Post：

	```
	[XDataService startPostWithURL:@"http://httpbin.org/post" dict:@{@"test":@"value"} cBlock:^(id result) {
	        NSLog(@"%@",result);
	    } fBlock:^(id error) {
	        NSLog(@"%@",error);
	    }];
	```


* 同步Get：

	```
	[XDataService startSyncGetWithURL:@"http://httpbin.org/get" cBlock:^(id result) {
	            NSLog(@"成功 time：%@",[NSDate new]);
	        } fBlock:^(id error) {
	            NSLog(@"fail time：%@",[NSDate new]);
	        }];
	```

* 同步Post：

	```
	[XDataService startSyncPostWithURL:@"http://httpbin.org/post" dict:@{@"test":@"value"} cBlock:^(id result) {
	            NSLog(@"成功 time：%@",[NSDate new]);
	        } fBlock:^(id error) {
	            NSLog(@"fail time：%@",[NSDate new]);
	        }];
	```
	

---

#### 缓存方案

*缓存前提，一般缓存都是从服务端获取信息，不会像提交表单那样有复杂的参数；POST请求的参数一般为只有一层的字典，GET请求只有URL*

--

* 新建一个缓存管理类`XDBData`,开放两个方法：

```
///获取缓存数据
- (NSData *)getCacheDataWithURL:(NSString *)urlString dict:(NSDictionary *)dict;

///保存请求数据
- (void)saveDataWithData:(NSData *)data URL:(NSString *)urlString dict:(NSDictionary *)dict;

```

* 部分私有方法如下：

```

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static XDBData *dbData = nil;
    dispatch_once(&onceToken, ^{
        dbData = [[super allocWithZone:NULL]init];
    });
    
    NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/cachesData.db",NSHomeDirectory()];
    _dataDB = [FMDatabase databaseWithPath:path];
    [_dataDB open];
    [_dataDB executeUpdate:@"CREATE TABLE IF NOT EXISTS cItem (cKey text NOT NULL, cValue blob NOT NULL)"];
    
    return dbData;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [XDBData shareInstance];
}
- (instancetype)copyWithZone:(struct _NSZone *)zone{
    return [XDBData shareInstance];
}

```

1.缓存数据库只需要包含两个字段 `cKey` 和 `cValue`;

2.如果要缓存，把请求参数所有key升序排列，并转换为字符串；把URL和转化之后的字符串用`？`或`&`连接作为cKey；请求结果作为cValue保存到缓存数据库；如果是GET请求，URL直接作为key；

POST请求URL和参数生成的key示例如下：

	http://www.192.168.8.111:8080/api/getXXXlist?key1=value1&key2=value2

3.查找缓存方法具体实现：根据第二步获得的key在缓存数据库里面查找，找到返回，没有就调用缓存请求；

4.缓存请求，在网络请求框架里面添加带缓存的网络请求私有方法；

5.有更新时，服务端和手机端如何告知？

不可行方案：

* 使用推送：不能保证100%送达；
* 下拉刷新：有些场景无法实现，比如颜色选择数据源；

可行方案：

* 使用推送加同步按钮，点击同步按钮更新当前页面缓存数据；
