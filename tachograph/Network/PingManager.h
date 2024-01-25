//
//  PingManager.h
//  simplePing_test
//
//  Created by 1 on 2023/11/13.
//  Copyright © 2023 1. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN




typedef void(^CompletionHandler)(NSArray *);



@interface PingManager : NSObject
- (void)getReachableAddressArray:(NSArray *)addressList resultArray:(CompletionHandler)completionHandler;
@end





NS_ASSUME_NONNULL_END
