//
//  SinglePinger.m
//  simplePing_test
//
//  Created by 1 on 2023/11/13.
//  Copyright © 2023 1. All rights reserved.
//

#import "SinglePinger.h"
#import "SimplePing.h"

@implementation PingItem
@end



@interface SinglePinger() <SimplePingDelegate>
@property (nonatomic, strong) SimplePing *pinger;
@property (nonatomic, strong) NSTimer *sendTimer;
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, copy) PingCallBack pingCallBack;
@end




@implementation SinglePinger

//前置加号（+）的方法为类方法，可以直接用类名来调用的，它的作用主要是创建一个实例。
+ (instancetype)startWithHostName:(NSString *)hostName CallBack:(PingCallBack)pingCallBack
{
    return [[self alloc] startInitHostName:hostName CallBack:pingCallBack];
}

//前置减号（-）的方法为实例方法，必须使用类的实例才可以调用的。
- (instancetype)startInitHostName:(NSString *)hostName CallBack:(PingCallBack)pingCallBack
{
    self.pingCallBack = pingCallBack;//代码块回调
    self.hostName = hostName;
    
    // 初始化一个 SimplePing 实例，
    // 注意，这个 pinger 实例不能为临时变量，不然当前函数执行完毕后，pinger 实例就会被释放，那么它的 delegate 将不会执行。
    self.pinger = [[SimplePing alloc] initWithHostName:hostName];
    
    // 指定 pinger 的 delegate
    self.pinger.delegate = self;
    
    // 指定要 ping 的 IP 地址的类型
    self.pinger.addressStyle = SimplePingAddressStyleAny;
    
    // 调用 start 方法开始 ping
    [self.pinger start];
    
    return self;
}


- (void)cleanAndCallBackWithStatus:(SinglePingStatus)status
{
    PingItem *pingItem = [[PingItem alloc] init];
    pingItem.hostName = self.hostName;
    pingItem.status = status;
    if (self.pingCallBack)
    {
        self.pingCallBack(pingItem);//Block回调
    }
    
    [self.pinger stop];
    self.pinger = nil;
    
    [self.sendTimer invalidate];
    self.sendTimer = nil;
    
    //NSLog(@"stop finished");
}
    

- (void)cleanAndCallBackWithStatusSinglePingStatusFailToReceivePacket
{
    [self cleanAndCallBackWithStatus:SinglePingStatusFailToReceivePacket];
}


#pragma mark - Ping Delegate

//start 方法成功执行，可开始发送数据
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    //NSLog(@"didStartWithAddress");
    
    //调用 sendPingWithData: 方法发送数据
    [pinger sendPingWithData:nil]; // data 可传入 nil，此时 ping 发送的数据会有一个默认值。
    
    NSAssert(self.sendTimer == nil, @"timer can't be nil");
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:connectTimeout target:self selector:@selector(cleanAndCallBackWithStatusSinglePingStatusFailToReceivePacket) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.sendTimer forMode:NSDefaultRunLoopMode];
}

//start 方法执行失败，返回错误信息
- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    NSLog(@"%@", error.localizedDescription);
    [self cleanAndCallBackWithStatus:SinglePingStatusFailToReceivePacket];
}

//成功发送数据
- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    //NSLog(@"didSendPacket");/*联网状态下数据总能发送成功*/
}

//发送数据失败
- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    NSLog(@"didFailToSendPacket: %@", error.localizedDescription);
    [self cleanAndCallBackWithStatus:SinglePingStatusFailToReceivePacket];
}

//成功接收到之前 pinger 发送的数据
- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    NSLog(@"didReceivePingResponsePacket: %@",self.hostName);/*服务器连通才能接收到数据*/
    [self cleanAndCallBackWithStatus:SinglePingStatusDidReceivePacket];
}

//接收到到未知的数据
- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    //NSLog(@"didReceiveUnexpectedPacket: %@",self.addressString);
    [self cleanAndCallBackWithStatus:SinglePingStatusFailToReceivePacket];
}

@end
