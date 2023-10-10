//
//  TextTabBarController.h
//  tachograph
//
//  Created by 1 on 2023/5/31.
//  Copyright © 2023 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCellularData.h>
#import <ifaddrs.h>
#import <arpa/inet.h>



#define SCREEN_WIDTH                    [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT                   [[UIScreen mainScreen] bounds].size.height
#define BackgroundColor                 systemIndigoColor
#define HeightOfLabel                   SCREEN_HEIGHT/18
#define HeightOfTabBar                  SCREEN_HEIGHT/18
#define WidthOfLabel                    SCREEN_WIDTH
#define WidthOfTabBar                   SCREEN_WIDTH
#define SizeOfLabelText                 HeightOfLabel/2.3
#define SizeOfTabBarText                HeightOfTabBar/4




NS_ASSUME_NONNULL_BEGIN

@interface TextTabBarController : UITabBarController

@end

NS_ASSUME_NONNULL_END
