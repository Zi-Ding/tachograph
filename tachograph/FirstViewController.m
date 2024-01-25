//
//  FirstViewController.m
//  tachograph
//
//  Created by 1 on 2023/5/28.
//  Copyright © 2023 1. All rights reserved.
//

#import "FirstViewController.h"
#import "Reachability.h"
#import "PingManager.h"


@interface FirstViewController ()

#ifndef ARRAY
#define ARRAY
typedef struct
{
    uint8_t* array;    //数组头指针
    NSInteger size;      //数组大小
}Array;
#endif

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) NSString *localAddress;
@property (strong, nonatomic) NSString *remoteAddress;
@property (strong, nonatomic) PingManager *pingManager;
@property (strong, nonatomic)  IBOutlet UIImageView *imageView;
@property (strong, nonatomic)  IBOutlet UIImage *image;

@end



@implementation FirstViewController

    Array imageBuff;
    BOOL image_cam_flag = NO;// 0:数据流不是图像数据   1:数据流是图像数据
    BOOL internetEnable = NO;
    BOOL isQianduan = NO;
    BOOL isHouduan = NO;
    
    
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*设置查找按钮样式*/
    CGRect originFrame = self.searchButton.frame;
    originFrame.size.height = HeightOfSearchButton; //设置按钮高度
    originFrame.size.width  = WidthOfSearchButton;  //设置按钮宽度
    originFrame.origin.x    = 0;                    //设置按钮位置x
    originFrame.origin.y    = HeightOfLabel + HeightOfTabBar + IntervalBetweenTabbarAndSearchButton + HeightOfSearchButton;//设置按钮位置y
    self.searchButton.frame = originFrame;//按钮圆角在inspector设置
    self.searchButton.titleLabel.font = [UIFont systemFontOfSize:SizeOfSearchButtonTitle];//设置按钮title字体大小
    /*设置表格标签文本格式*/
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentLeft;//对齐
    CGFloat emptylen = SizeOfTableLabelText;//首行空出一个字符
    paraStyle.firstLineHeadIndent = emptylen;//首行缩进
    paraStyle.tailIndent = WidthOfTableLabel;//行尾缩进或显示宽度
    /*添加表格标签1*/
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, HeightOfLabel + HeightOfTabBar + IntervalBetweenTabbarAndSearchButton + HeightOfSearchButton + HeightOfTableLabel, WidthOfTableLabel, (int)HeightOfTableLabel)];//取整解决UILabel边线问题
    label1.font = [UIFont systemFontOfSize:SizeOfTableLabelText];
    label1.backgroundColor = [UIColor whiteColor];
    label1.text = [[NSString alloc] initWithFormat:@"位置"];
    label1.textColor = [UIColor grayColor];
    NSString *textstring1 = [[NSString alloc] initWithFormat:@"位置"];
    NSAttributedString *attrText1 = [[NSAttributedString alloc] initWithString:textstring1 attributes:@{NSParagraphStyleAttributeName:paraStyle}];
    label1.attributedText = attrText1;
    [self.view addSubview:label1];
    /*添加表格标签2*/
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(WidthOfTableLabel*1 , HeightOfLabel + HeightOfTabBar + IntervalBetweenTabbarAndSearchButton + HeightOfSearchButton + HeightOfTableLabel, WidthOfTableLabel, (int)HeightOfTableLabel)];//取整解决UILabel边线问题
    label2.font = [UIFont systemFontOfSize:SizeOfTableLabelText];
    label2.backgroundColor = [UIColor whiteColor];
    label2.text = [[NSString alloc] initWithFormat:@"IP"];
    label2.textColor = [UIColor grayColor];
    NSString *textstring2 = [[NSString alloc] initWithFormat:@"IP"];
    NSAttributedString *attrText2 = [[NSAttributedString alloc] initWithString:textstring2 attributes:@{NSParagraphStyleAttributeName:paraStyle}];
    label2.attributedText = attrText2;
    [self.view addSubview:label2];
    /*添加表格标签3*/
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(WidthOfTableLabel*2 , HeightOfLabel + HeightOfTabBar + IntervalBetweenTabbarAndSearchButton + HeightOfSearchButton + HeightOfTableLabel, WidthOfTableLabel, (int)HeightOfTableLabel)];//取整解决UILabel边线问题
    label3.font = [UIFont systemFontOfSize:SizeOfTableLabelText];
    label3.backgroundColor = [UIColor whiteColor];
    label3.text = [[NSString alloc] initWithFormat:@"操作"];
    label3.textColor = [UIColor grayColor];
    NSString *textstring3 = [[NSString alloc] initWithFormat:@"操作"];
    NSAttributedString *attrText3 = [[NSAttributedString alloc] initWithString:textstring3 attributes:@{NSParagraphStyleAttributeName:paraStyle}];
    label3.attributedText = attrText3;
    [self.view addSubview:label3];
}


- (NSString *)documentFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    //NSLog(@"%@",documentDirectory);
    return [documentDirectory stringByAppendingPathComponent:@"tachograph"];
    //return documentDirectory;
}

- (NSString *)tmpFilePath
{
    return NSTemporaryDirectory();
}

- (NSString *)getTime
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy年MM月dd日HH时mm分"];
    NSString *dateString = [dateFormat stringFromDate:currentDate];
    return dateString;
}


- (NSString *)getLocalIPAddress
{
    NSString *address;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;

    // retrieve the current interfaces - returns 0 on success

    int success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        
        while(temp_addr != NULL)
        {
            // Check for IPV4 interface
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                //NSLog(@"Found a new interface in domain TCP/IP – IPv4: %@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                
                //en开头为网卡接口, pdp_ip开头为蜂窝数据, lo0为环回接口(LocalHost常为本地测试用)， bridge100为桥接或热点HostIp
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] hasPrefix:@"bridge"])
                {
                    NSLog(@"ifa_name with <> prefix = %@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];//Get NSString from C String
                    NSLog(@"%@ address = %@",[NSString stringWithUTF8String:temp_addr->ifa_name],address);
                    break;
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;//遍历所有网卡
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}


- (IBAction)searchButtonPressed:(id)sender
{
    //[self checkNeedPermissions];//检测网络权限，实测后发现一直是kCTCellularDataRestrictedStateUnknown
    
    internetEnable = [self reachabilityForNetworkConnection];//利用Reachability判断当前设备是否联网
    if (internetEnable)
    {
        self.localAddress = [self getLocalIPAddress];
        NSLog(@"localAddress = %@",self.localAddress);
        if (self.localAddress)
        {
            [self searchHotIP:self.localAddress];//利用SimplePing来检查服务器是否连通
        }
    }
}


- (void)searchHotIP:(NSString *)IPString
{
    /*由于联网状态下ICMP数据总能发送成功，所以判断服务器ip的时候不能用Reachability，要用SimplePing*/
    
    NSRange range = [IPString rangeOfString:@"." options:NSBackwardsSearch];
    NSString *headString = [IPString substringToIndex:1 + range.location];
    NSLog(@"headString = %@",headString);
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (int i = 1; i<=255; i++)
    {
        NSString *intString = [NSString stringWithFormat:@"%d",i];
        NSString *tempAddressString = [headString stringByAppendingString:intString];
        if ([tempAddressString isEqualToString:self.localAddress]||[tempAddressString isEqualToString:@"172.20.10.15"])//热点自己的地址是172.20.10.1, 广播地址是 172.20.10.15
        {
            continue;
        }
        [mutableArray addObject:tempAddressString];
    }
    NSArray *addressArray = [NSArray arrayWithArray:mutableArray];
    
    self.pingManager = [[PingManager alloc] init];
    [self.pingManager getReachableAddressArray:addressArray resultArray:(CompletionHandler)^(NSArray *resultAddress)
    {
        NSLog(@"resultAddress:\n%@",resultAddress);
        if (resultAddress)
        {
            [self searchForCamera:resultAddress];
        }
    }];
}


- (void)searchForCamera:(NSArray *)addressList
{   
    for (NSString *address in addressList)
    {
        [self createTestSocketByAddress:address];
    }
}


- (void)createTestSocketByAddress:(NSString *)address
{
    NSLog(@"addressStr = %@",address);
    
    if (address)
    {
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        
        /*通过CFStream创建的socket连接*/
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)(address), PortOfSocket, &readStream, &writeStream);
        
        NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;//CFStream转换至NSStream
        NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;//CFStream转换至NSStream
        
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];//按照默认顺序运行inputStreamEvent
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];//按照默认顺序运行outputStreamEvent
        
        [inputStream open];
        [outputStream open];
    }
    else
    {
        NSLog(@"addressStr is null");
    }
}


- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode //该方法是NSStreamDelegate协议方法，对事件的响应方法
{
    switch(eventCode )
    {
        case NSStreamEventOpenCompleted:  //打开完成事件
        {
            NSLog(@"NSStreamEventOpenCompleted");
            break;
        }
        case NSStreamEventHasBytesAvailable:  //可读的事件响应处理
        {
            NSLog(@"NSStreamEventHasBytesAvailable");
            
            //uint8_t RevBuff[1024] = {69,115,112,51,50,77,115,103,67,108,105,101,110,116,32,105,115,32,67,111,110,110,101,99,116,33,105,100,49};
            //NSMutableData *data;
            BOOL msg_begin = NO;
            uint8_t RevBuff[1024];
            NSInteger len = 0;
            
            len = [(NSInputStream *)stream read:RevBuff maxLength:1024];//Returns the actual number of bytes read.
            if(len)
            {
                //[data appendBytes:(const void *)RevBuff length:len];
                NSString *RevBuffString = [NSString stringWithFormat:@"%s",RevBuff];
                NSLog(@"RevBuffString = %@",RevBuffString);
                
                msg_begin = RevBuff[0] == 69 && RevBuff[1] == 115 && RevBuff[2] == 112 && RevBuff[3] == 51 && RevBuff[4] == 50
                && RevBuff[5] == 77 && RevBuff[6] == 115 && RevBuff[7] == 103 ;//判断包头
                if (msg_begin)
                {
                    /*处理接收到的握手信息帧*/
                    NSRange range1 = [RevBuffString rangeOfString:@"Esp32MsgClient is Connect!"];
                    if (range1.location != NSNotFound)
                    {
                        NSRange range2 = [RevBuffString rangeOfString:@"id1"];
                        NSRange range3 = [RevBuffString rangeOfString:@"id2"];
                        if (range2.location != NSNotFound)//前端
                        {
                            NSLog(@"qianduan");
                            //[self showSearchResult:@"前端" withIP:address];//开启直播
                        }
                        else if (range3.location != NSNotFound)//后端
                        {
                            NSLog(@"houduan");
                        }
                    }
                    
                    NSString *FrontendOrBackend  = @"";
                    if ([FrontendOrBackend isEqualToString:@"qianduan"] || [FrontendOrBackend isEqualToString:@"houduan"])
                    {
                        //[self showSearchResult:FrontendOrBackend withIP:address];//开启直播
                    }
                }
                
            }
            else
            {
                NSLog(@"RevBuff len = null !");
            }
            break;
        }
        case NSStreamEventHasSpaceAvailable:   //可写的事件响应处理
        {
            NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
        }
        case NSStreamEventEndEncountered:  //结束事件
        {
            NSLog(@"NSStreamEventEndEncountered");
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            stream = nil; // stream is ivar, so reinit it
            break;
        }
        case NSStreamEventNone:
        {
            NSLog(@"NSStreamEventNone");
            break;
        }
        case NSStreamEventErrorOccurred:  //错误发生事件
        {
            NSLog(@"NSStreamEventErrorOccurred");
            NSError *theError = [stream streamError];
            NSLog(@"Error %li: %@", (long)[theError code], [theError localizedDescription]);
            [stream close];
            break;
        }
    }
}


- (void)showSearchResult:(NSString *)FrontendOrBackend withIP:(NSString *)ipString
{
    /*设置表格文本格式*/
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentLeft;//对齐
    CGFloat emptylen = SizeOfTableText*1;//首行空出1个字符
    paraStyle.firstLineHeadIndent = emptylen;//首行缩进
    paraStyle.tailIndent = WidthOfTable;//行尾缩进或显示宽度
    /*添加表格内容1*/
    UILabel *tableContent1 = [[UILabel alloc]initWithFrame:CGRectMake(0, HeightOfLabel + HeightOfTabBar + IntervalBetweenTabbarAndSearchButton + HeightOfSearchButton + HeightOfTableLabel + HeightOfTable, WidthOfTable, (int)HeightOfTable)];//取整解决UILabel边线问题
    tableContent1.font = [UIFont systemFontOfSize:SizeOfTableText];
    tableContent1.backgroundColor = [UIColor whiteColor];
    tableContent1.text = [[NSString alloc] initWithString:FrontendOrBackend];
    tableContent1.textColor = [UIColor blackColor];
    NSString *textstring1 = [[NSString alloc] initWithString:FrontendOrBackend];
    NSAttributedString *attrText1 = [[NSAttributedString alloc] initWithString:textstring1 attributes:@{NSParagraphStyleAttributeName:paraStyle}];
    tableContent1.attributedText = attrText1;
    [self.view addSubview:tableContent1];
    /*添加表格内容2*/
    UILabel *tableContent2 = [[UILabel alloc]initWithFrame:CGRectMake(WidthOfTable*1 , HeightOfLabel + HeightOfTabBar + IntervalBetweenTabbarAndSearchButton + HeightOfSearchButton + HeightOfTableLabel + HeightOfTable, WidthOfTable, (int)HeightOfTable)];//取整解决UILabel边线问题
    tableContent2.font = [UIFont systemFontOfSize:SizeOfTableText];
    tableContent2.backgroundColor = [UIColor whiteColor];
    tableContent2.text = [[NSString alloc] initWithString:ipString];
    tableContent2.textColor = [UIColor blackColor];
    NSString *textstring2 = [[NSString alloc] initWithString:ipString];
    NSAttributedString *attrText2 = [[NSAttributedString alloc] initWithString:textstring2 attributes:@{NSParagraphStyleAttributeName:paraStyle}];
    tableContent2.attributedText = attrText2;
    [self.view addSubview:tableContent2];
    /*设置连接按钮样式*/
    CGRect originFrame1 = self.connectButton.frame;
    originFrame1.size.height = HeightOfConnectButton; //设置按钮高度
    originFrame1.size.width  = WidthOfConnectButton;  //设置按钮宽度
    originFrame1.origin.x    = WidthOfTable*2;                    //设置按钮位置x
    originFrame1.origin.y    = HeightOfLabel + HeightOfTabBar + IntervalBetweenTabbarAndSearchButton + HeightOfSearchButton + HeightOfTableLabel + HeightOfTable;//设置按钮位置y
    self.connectButton.frame = originFrame1;
    self.connectButton.titleLabel.font = [UIFont systemFontOfSize:SizeOfConnectButtonTitle];//设置按钮title字体大小
    self.connectButton.hidden = NO;
}


- (IBAction)connectButtonPressed:(UIButton *)sender
{
    if ([self.connectButton.currentTitle isEqual: @"连接"] && self.connectButton.enabled == YES)
    {
        self.connectButton.enabled = NO;//
        [self.connectButton setTitle:@"正在获取图像" forState:UIControlStateNormal];//与inputStreamReceiveImageMessage有关
        
        //NSDate *clickTime = [NSDate date];
        //NSLog(@"clickTime = %@",clickTime);
        
        //NSDate *nowDate = [NSDate date];
        //NSTimeInterval timeIntervalSinceClickConnectButton = [nowDate timeIntervalSinceDate:clickTime];
        //NSLog(@"timeIntervalSinceClickConnectButton = %f",timeIntervalSinceClickConnectButton);
        
        //[self createSocketByAddress:self.];
        
        //[self stream:inputStream handleEvent:NSStreamEventOpenCompleted];//运行Stream打开完成事件
        
        //NSString *tmpFilePath = [self tmpFilePath];
        //NSLog(@"tmpFilePath = %@",tmpFilePath);
        NSString *documentFilePath = [self documentFilePath];
        NSString *currentTime = [self getTime];
        NSString *mp4FileName = [currentTime stringByAppendingString:@".mp4"];
        NSString *mp4FilePath =[documentFilePath stringByAppendingPathComponent:mp4FileName];
        NSLog(@"mp4FilePath = %@",mp4FilePath);
        
        //[self inputStreamReceiveImageMessage:inputStream];//inputstream读入camera消息
        
        
        
        //[self stream:inputStream handleEvent:NSStreamEventEndEncountered];//运行Stream结束事件
        
    }
    
}


- (void)inputStreamReceiveImageMessage:(NSStream *)stream
{
    uint8_t RevBuff[1024];//注意数据类型uint8与int8
    NSInteger len = 0;//注意长度,long和int
    len = [(NSInputStream *)stream read:RevBuff maxLength:1024];//Returns the actual number of bytes read.
    
    if(len)
    {
        //图像数据包的头  FrameBegin
        BOOL begin_cam_flag = RevBuff[0] == 70 && RevBuff[1] == 114 && RevBuff[2] == 97 && RevBuff[3] == 109 && RevBuff[4] == 101
        && RevBuff[5] == 66 && RevBuff[6] == 101 && RevBuff[7] == 103 && RevBuff[8] == 105 && RevBuff[9] == 110 ;
        //图像数据包的尾  FrameOverr
        BOOL end_cam_flag = RevBuff[0] == 70 && RevBuff[1] == 114 && RevBuff[2] == 97 && RevBuff[3] == 109 && RevBuff[4] == 101
                && RevBuff[5] == 79 && RevBuff[6] == 118 && RevBuff[7] == 101 && RevBuff[8] == 114 && RevBuff[9] == 114;
        if (!image_cam_flag && begin_cam_flag)//判断接收的包是不是图片的开头数据,是的话说明下面的数据属于图片数据,将image_cam_flag置1
        {
            image_cam_flag = YES;
        }
        else if (image_cam_flag)//如果 image_cam_flag == 1,说明包是图像数据,将数据发给byteMerger方法,合并一帧图像
        {
            array_create(&imageBuff, 0);//创建数组
            NSInteger recvBuffSize = len;//注意long和int
            [self byteMergerBetweenWholeBuff:&imageBuff andReciveBuff:RevBuff RecvBuffSize:recvBuffSize];
        }
        else if (end_cam_flag)//判断包是不是图像的结束包,是的话将image_cam_flag置0，并显示图像
        {
            image_cam_flag = NO;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),//异步并发线程
            ^{
                
                self.image = [self creatUIImageByData:imageBuff.array];
                
                dispatch_async(dispatch_get_main_queue(),//回到主线程追加任务
                ^{
                    
                    [self.imageView setImage:self.image];

                    array_free(&imageBuff);
                });
            
            });
        }
        
        //定义包头  Esp32Msg
        BOOL begin_msg_begin = RevBuff[0] == 69 && RevBuff[1] == 115 && RevBuff[2] == 112 && RevBuff[3] == 51 && RevBuff[4] == 50
                && RevBuff[5] == 77 && RevBuff[6] == 115 && RevBuff[7] == 103;
        //判断包头
        if(begin_msg_begin)
        {
            //unknown using method
            NSLog(@"begin_msg_begin!");
        }
    }
}


-(UIImage *)creatUIImageByData:(uint8_t *)pointer
{
    CGContextRef bitmapContext = CGBitmapContextCreate(pointer,
                                                       100,
                                                       100,
                                                       8,
                                                       100 * 4,
                                                       CGColorSpaceCreateDeviceRGB(),
                                                       kCGImageAlphaPremultipliedFirst);
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];//can try [[UIImage alloc] initWithData:data]
    
    CGImageRelease(imageRef);
    CGContextRelease(bitmapContext);
    
    return image;
}


#pragma mark - C ArrayList

void array_create(Array *a, NSInteger init_size)
{
    a->size = init_size;
    a->array = (uint8_t *)malloc(sizeof(uint8_t) * a->size);
}

void array_set(Array *a, NSInteger index, NSInteger value)
{
    a->array[index] = value;
}

void array_free(Array *a)
{
    free(a->array);
    a->array = NULL;
    a->size = 0;
}

- (void)byteMergerBetweenWholeBuff:(Array *)wholeBuff  andReciveBuff:(uint8_t *)recvBuff RecvBuffSize:(NSInteger)recvBuffSize
{
    //分配内存空间大小为wholeBuffSize+recvBuffSize
    uint8_t *tempBuff = (uint8_t *)malloc((wholeBuff->size + recvBuffSize) * sizeof(uint8_t));
    
    //复制wholebuff原内容
    memcpy(tempBuff, wholeBuff->array, wholeBuff->size);
    
    //添加recvBuff内容至尾端
    for (int i = 0; i<recvBuffSize; i++)
    {
        tempBuff[i + wholeBuff->size] = recvBuff[i];
    }
    
    //计算合并后数组长度
    NSInteger mergerBuffSize = wholeBuff->size + recvBuffSize;
    
    //释放原数组指针所指内容
    free(wholeBuff->array);
    
    //更新数组信息
    wholeBuff->array = tempBuff;
    wholeBuff->size = mergerBuffSize;
    
}


#pragma mark - Network Reachability

- (void)checkNeedPermissions
{
    /*查询是否有网络权限*/
    /*ios系统没有提供接口供APP开发者手动请求网络权限，应用首次请求网络时，系统会自动弹出权限选择框。一个应用只会弹出一次提示，提示过后就算卸载重装也不再提示*/
    CTCellularData *cellularData = [[CTCellularData alloc]init];
    CTCellularDataRestrictedState state = cellularData.restrictedState;
     switch (state)
     {
       case kCTCellularDataRestricted:
         {
             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"受限的网络权限"
                                            message:@"为了您的使用体验，请同意授予WLAN与蜂窝移动网权限"
                                            preferredStyle:UIAlertControllerStyleAlert];
              
             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * action) {}];
              
             [alert addAction:defaultAction];
             [self presentViewController:alert animated:YES completion:nil];
         }
             break;
       case kCTCellularDataNotRestricted:
             //NSLog(@"Not Restricted");
             break;
       case kCTCellularDataRestrictedStateUnknown:
         {
             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"未知的网络权限"
                                            message:@"为了您的使用体验，请同意授予WLAN与蜂窝移动网权限"
                                            preferredStyle:UIAlertControllerStyleAlert];
            
             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * action) {}];
             
             [alert addAction:defaultAction];
             [self presentViewController:alert animated:YES completion:nil];
         }
             break;
       default:
             break;
    }
    
    /*存储权限实机测试时调整，查看是否与网络权限申请一样是系统自动申请*/
    
}

- (BOOL)reachabilityForNetworkConnection
{
    /*当应用程序发送到网络堆栈的数据包可以离开本地设备时，就可以认为远程主机是可访问的，但不能保证主机是否实际接收到数据包*/
    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
    BOOL internetConnectionEnable = NO;
    NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"NotReachable");
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"无网络"
                                            message:@"NotReachable"
                                            preferredStyle:UIAlertControllerStyleAlert];
            
             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * action) {}];
             
             [alert addAction:defaultAction];
             [self presentViewController:alert animated:YES completion:nil];
            
            internetConnectionEnable = NO;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"ReachableViaWWAN");
            internetConnectionEnable = YES;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"ReachableViaWiFi");
            internetConnectionEnable = YES;
            break;
        }
    }
    
    return internetConnectionEnable;
    
}

@end
