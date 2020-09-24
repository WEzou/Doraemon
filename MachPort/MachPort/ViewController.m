//
//  ViewController.m
//  OC-App
//
//  Created by zw on 2020/9/22.
//  Copyright © 2020 zw. All rights reserved.
//

#import "ViewController.h"
#import "MachPortWork.h"

@interface ViewController ()<NSMachPortDelegate>

@property(nonatomic, strong)MachPortWork *work;
@property(nonatomic, strong)NSPort *remotePort;
@property(nonatomic, strong)NSPort *localPort;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMachPort *port = [NSMachPort port];
    NSLog(@"main port: %u",port.machPort);
    port.delegate = self;
    _localPort = port;
    [[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
    
    MachPortWork *work = [[MachPortWork alloc] init];
    [NSThread detachNewThreadSelector:@selector(launchThread:) toTarget:work withObject:port];
}

- (void)handlePortMessage:(id)message {
        
    //1. 消息id
    NSUInteger msgId = [[message valueForKeyPath:@"msgid"] integerValue];
    //2. 当前主线程的port
    NSMachPort *localPort = [message valueForKeyPath:@"localPort"];
    //3. 接收到消息的port（来自其他线程）
    NSMachPort *remotePort = [message valueForKeyPath:@"remotePort"];
    _remotePort = remotePort;
    //4. 接收到消息的components（来自其他线程）
    NSMutableArray *array = [message valueForKeyPath:@"components"];
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    for (NSData *data in array) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [strings addObject:string];
    }
    
    NSLog(@"msgId = %lu, localPort = %u, remotePort = %u, components = %@",(unsigned long)msgId,localPort.machPort,remotePort.machPort,strings);
}

- (void)sendMessage {
    NSData *data = [@"main->child" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *components = [NSMutableArray arrayWithArray:@[data]];
    BOOL result = [_remotePort sendBeforeDate:[NSDate date] msgid:101 components:components from:_localPort reserved:0];
    NSLog(@"send result: %d ----------------",result);
}

- (IBAction)send:(UIButton *)sender {
    [self sendMessage];
}

@end


