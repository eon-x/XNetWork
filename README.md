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