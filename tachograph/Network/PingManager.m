//
//  PingManager.m
//  simplePing_test
//
//  Created by 1 on 2023/11/13.
//  Copyright © 2023 1. All rights reserved.
//

#import "PingManager.h"
#import "SinglePinger.h"



@interface PingManager ()
@property (nonatomic, strong) NSMutableArray *singlePingerArray;
@end



@implementation PingManager

- (void)getReachableAddressArray:(NSArray *)addressList resultArray:(CompletionHandler)completionHandler
{
    if (addressList.count == 0)
    {
        NSLog(@"addressList can't be empty");
        return;
    }
    
    self.singlePingerArray = [NSMutableArray array];
    NSMutableArray *resultArray = [NSMutableArray array];
    
    dispatch_group_t group = dispatch_group_create();
    for (NSString *address in addressList)
    {   
        SinglePinger *singlePinger = [SinglePinger startWithHostName:address CallBack:^(PingItem *pingitem)
        {
            switch (pingitem.status)
            {
                case SinglePingStatusDidReceivePacket:
                    {
                        if (![resultArray containsObject:pingitem.hostName])
                        {
                            [resultArray addObject:pingitem.hostName];
                        }
                        dispatch_group_leave(group);
                    }
                    break;
                case SinglePingStatusFailToReceivePacket:
                    dispatch_group_leave(group);
                    break;
                default:
                    break;
            }
        }];
        dispatch_group_enter(group);
        [self.singlePingerArray addObject:singlePinger];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(),
    ^{
        NSArray *addressArray = [NSArray arrayWithArray:resultArray];
        completionHandler(addressArray);//回调
    });
}

@end
