//
//  GCDAsyncSocketVC.m
//  ClientSocket
//
//  Created by xingl on 2019/1/24.
//  Copyright © 2019 xingl. All rights reserved.
//

#import "GCDAsyncSocketVC.h"
#import <GCDAsyncSocket.h>

@interface GCDAsyncSocketVC ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *clientSocket;

@end

@implementation GCDAsyncSocketVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 300, 60)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"发送数据" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    [self.clientSocket connectToHost:@"127.0.0.1" onPort:12345 error:&error];
    if (error) {
        NSLog(@"error == %@",error);
    }
}

- (void)clickBtn {
    
    NSString *msg = @"你好\r\n";
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    [self.clientSocket writeData:data withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"链接成功");
    NSLog(@"服务器IP: %@-------端口: %d",host,port);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"发送数据 tag = %zi",tag);
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"读取数据 data = %@ tag = %zi",str,tag);
    // 读取到服务端数据值后,能再次读取
    [sock readDataWithTimeout:- 1 tag:tag];
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"xx断开连接");
    self.clientSocket.delegate = nil;
    self.clientSocket = nil;
}

@end
