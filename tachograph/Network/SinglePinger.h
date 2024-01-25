//
//  SinglePinger.h
//  simplePing_test
//
//  Created by 1 on 2023/11/13.
//  Copyright © 2023 1. All rights reserved.
//

#import <Foundation/Foundation.h>

#define connectTimeout                                3

NS_ASSUME_NONNULL_BEGIN




@class PingItem;
typedef void(^PingCallBack)(PingItem *pingitem);

typedef NS_ENUM(NSUInteger, SinglePingStatus)
{
    SinglePingStatusDidReceivePacket,
    SinglePingStatusFailToReceivePacket,
};

@interface PingItem : NSObject
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, assign) SinglePingStatus status;
@end



@interface SinglePinger : NSObject
+ (instancetype)startWithHostName:(NSString *)hostName CallBack:(PingCallBack)pingCallBack;
- (instancetype)startInitHostName:(NSString *)hostName CallBack:(PingCallBack)pingCallBack;
@end




NS_ASSUME_NONNULL_END
