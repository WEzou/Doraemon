//
//  MachPortWork.m
//  OC-App
//
//  Created by zw on 2020/9/23.
//  Copyright © 2020 zw. All rights reserved.
//

#import "MachPortWork.h"

@interface MachPortWork ()<NSMachPortDelegate>

@property(nonatomic, strong)NSPort *remotePort;
@property(nonatomic, strong)NSPort *localPort;

@end

@implementation MachPortWork

- (void)launchThread:(NSPort *)remotePort {
    
    @autoreleasepool {
        
        _remotePort = remotePort;
        
        [[NSThread currentThread] setName:@"MachPortWork"];
        [self addObserver];
        
        NSMachPort *port = [NSMachPort port];
        port.delegate = self;
        _localPort = port;
        NSLog(@"work port: %u",port.machPort);
        
        [[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
        [self sendMessage];
        [[NSRunLoop currentRunLoop] run];   //执行完一次任务就退出、然后再次进入
    }
}

- (void)sendMessage {
    
    NSData *data = [@"child->main" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[data]];
    [_remotePort sendBeforeDate:[NSDate date] msgid:100 components:array from:_localPort reserved:0];
}

- (void)handlePortMessage:(id)message {
    //1. 消息id
    NSUInteger msgId = [[message valueForKeyPath:@"msgid"] integerValue];
    //2. 当前主线程的port
    NSMachPort *localPort = [message valueForKeyPath:@"localPort"];
    //3. 接收到消息的port（来自其他线程）
    NSMachPort *remotePort = [message valueForKeyPath:@"remotePort"];
    //4. 接收到消息的components（来自其他线程）
    NSMutableArray *array = [message valueForKeyPath:@"components"];
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    for (NSData *data in array) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [strings addObject:string];
    }
    NSLog(@"msgId = %lu, localPort = %u, remotePort = %u, array = %@",(unsigned long)msgId,localPort.machPort,remotePort.machPort,strings);
}

- (void)addObserver {
    
    NSString *name = [[NSThread currentThread] name];
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        
        switch (activity) {
            case kCFRunLoopEntry:
                NSLog(@"%@: 即将进入runloop",name);
                break;
            case kCFRunLoopBeforeTimers:
                NSLog(@"%@: 即将处理timer事件",name);
                break;
            case kCFRunLoopBeforeSources:
                NSLog(@"%@: 即将处理source事件",name);
                break;
            case kCFRunLoopBeforeWaiting:
                NSLog(@"%@: 即将进入睡眠",name);
                break;
            case kCFRunLoopAfterWaiting:
                NSLog(@"%@: 被唤醒",name);
                break;
            case kCFRunLoopExit:
                NSLog(@"%@: runloop退出",name);
                break;
            default:
                break;
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetCurrent(),observer, kCFRunLoopDefaultMode);
    CFRelease(observer);
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
