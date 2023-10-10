//
//  TextTabBar.m
//  tachograph
//
//  Created by 1 on 2023/5/30.
//  Copyright © 2023 1. All rights reserved.
//

#import "TextTabBar.h"

@implementation TextTabBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = CGRectMake(0, HeightOfLabel + HeightOfTabBar, WidthOfTabBar, HeightOfTabBar);//设置tabbar矩形位置与长宽
    
    //self.backgroundColor = [UIColor blueColor];    /*tabbar的背景颜色也可在inspectors设置*/
}


@end
