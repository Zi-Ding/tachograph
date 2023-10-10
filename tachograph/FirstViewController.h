//
//  FirstViewController.h
//  tachograph
//
//  Created by 1 on 2023/5/28.
//  Copyright © 2023 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import "TextTabBar.h"
#import "TextTabBarController.h"
#import "Reachability.h"


#define IntervalBetweenTabbarAndSearchButton        SCREEN_HEIGHT/45

#define HeightOfSearchButton                        SCREEN_HEIGHT/25
#define WidthOfSearchButton                         SCREEN_WIDTH/5
#define SizeOfSearchButtonTitle                     HeightOfSearchButton/2.5

//#define IntervalBetweenSearchButtonAndTableLabel    SCREEN_HEIGHT/40

#define HeightOfTableLabel                          SCREEN_HEIGHT/20
#define WidthOfTableLabel                           SCREEN_WIDTH/3
#define SizeOfTableLabelText                        HeightOfTableLabel/2.5

#define PortOfSocket                                8080

#define qianduan                                    @"前端"
#define houduan                                     @"后端"

#define HeightOfTable                               SCREEN_HEIGHT/20
#define WidthOfTable                                SCREEN_WIDTH/3
#define SizeOfTableText                             HeightOfTableLabel/3

#define HeightOfConnectButton                       SCREEN_HEIGHT/20
#define WidthOfConnectButton                        SCREEN_WIDTH/4
#define SizeOfConnectButtonTitle                    HeightOfSearchButton/2.8


@interface FirstViewController : UIViewController



@end

