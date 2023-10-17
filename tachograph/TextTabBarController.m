//
//  TextTabBarController.m
//  tachograph
//
//  Created by 1 on 2023/5/31.
//  Copyright © 2023 1. All rights reserved.
//

#import "TextTabBarController.h"

@interface TextTabBarController ()

@end

@implementation TextTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*添加自定义顶部标签*/
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, HeightOfLabel, WidthOfLabel, HeightOfLabel)];
    label.font = [UIFont systemFontOfSize:SizeOfLabelText];
    if (@available(iOS 13.0, *)) {
        label.backgroundColor = [UIColor BackgroundColor];
    } else {
        // Fallback on earlier versions
    }
    label.text = [[NSString alloc] initWithFormat:@"tachograph"];
    label.textColor = [UIColor whiteColor];
    /*设置顶部标签文本格式*/
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentLeft;//对齐
    CGFloat emptylen = SizeOfLabelText * 2;//字体大小乘以2 即首行空出两个字符
    paraStyle.firstLineHeadIndent = emptylen;//首行缩进
    paraStyle.tailIndent = SizeOfLabelText;//行尾缩进或显示宽度
    NSString *textstring = [[NSString alloc] initWithFormat:@"tachograph"];
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:textstring attributes:@{NSParagraphStyleAttributeName:paraStyle}];
    label.attributedText = attrText;
    [self.view addSubview:label];
    
    
    /*tabbaritems的标题文本位置在inspectors设置*/
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont  systemFontOfSize:SizeOfTabBarText]}
    forState:UIControlStateNormal];//设置常态tabbaritems的标题文本大小
    if (@available(iOS 13.0, *)) {
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor BackgroundColor]}
                                                 forState:UIControlStateSelected];
    } else {
        // Fallback on earlier versions
    }//设置被选中tabbaritem的标题文本颜色
    
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
