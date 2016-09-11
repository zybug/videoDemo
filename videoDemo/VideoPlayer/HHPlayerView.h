//
//  HHPlayerView.h
//  VideoDemo
//
//  Created by localadmin on 16/9/9.
//  Copyright © 2016年 searainbow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@class HHFullPlayerViewController;
@interface HHPlayerView : UIView

// 播放器
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, copy) NSString *urlString; // 网址

@property (nonatomic, weak) UIViewController *contrainerViewController; // 包含在那个视图
@property (nonatomic, strong) HHFullPlayerViewController *fullViewController;

#pragma mark - IB

@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;




#pragma mark - func

+ (instancetype)sharedPlayerView;
- (void)showToolsView:(BOOL)isShow;

@end
