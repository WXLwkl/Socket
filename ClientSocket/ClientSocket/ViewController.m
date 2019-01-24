//
//  ViewController.m
//  ClientSocket
//
//  Created by xingl on 2019/1/23.
//  Copyright © 2019 xingl. All rights reserved.
//

#import "ViewController.h"

#import <sys/socket.h>
#import <arpa/inet.h>
#import <netinet/in.h>


@interface ViewController ()
{
    NSString *myName;
    CFSocketRef _socket;
    BOOL isOnline;
}
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self configServer];
}


- (IBAction)send:(id)sender {
    if (isOnline) {
        NSString *stringToSend = [NSString stringWithFormat:@"lin说:%@",self.inputField.text];
        self.inputField.text = nil;
        const char *data = [stringToSend UTF8String];
        send(CFSocketGetNative(_socket), data, strlen(data) + 1, 1);
    }else{
        NSLog(@"未连接服务器");
    }
}

- (void)configServer {
    //创建socket无需回调函数
    _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketNoCallBack, nil, NULL);
    if (_socket != nil) {
        //        定义sockadd_in    作为cfsocket的地址
        struct sockaddr_in addr4;
        memset(&addr4, 0, sizeof(addr4));
        addr4.sin_len = sizeof(addr4);
        addr4.sin_family = AF_INET;
        //        设置远程服务器地址
        addr4.sin_addr.s_addr = inet_addr("127.0.0.1");
        addr4.sin_port = htons(12345);
        CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr4, sizeof(addr4));
        CFSocketError result = CFSocketConnectToAddress(_socket, address, 5);
        if (result == kCFSocketSuccess) {
            isOnline = YES;
            [NSThread detachNewThreadSelector:@selector(readStream) toTarget:self withObject:nil];
        }
    }
}

- (void)readStream {
    char buffer[2048];
    ssize_t hadRead;
    //    与本机相连的socket如果已经失效，则返回-1
    while (hadRead = recv(CFSocketGetNative(_socket), buffer, sizeof(buffer), 0)) {
        NSString *contend = [[NSString alloc] initWithBytes:buffer length:hadRead encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.showLabel.text = [NSString stringWithFormat:@"%@\n%@",contend,self.showLabel.text];
            NSLog(@"%@\n",contend);
        });
    }
}

@end
