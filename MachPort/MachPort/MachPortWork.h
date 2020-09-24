//
//  MachPortWork.h
//  OC-App
//
//  Created by zw on 2020/9/23.
//  Copyright © 2020 zw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MachPortWork : NSObject

- (void)launchThread:(NSPort *)remotePort;

@end

NS_ASSUME_NONNULL_END
