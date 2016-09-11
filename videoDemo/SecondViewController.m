//
//  SecondViewController.m
//  videoDemo
//
//  Created by zy on 16/9/11.
//  Copyright © 2016年 zy. All rights reserved.
//

#import "SecondViewController.h"
#import "HHPlayerView.h"

#define kScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

@interface SecondViewController ()

@property (nonatomic, strong) HHPlayerView *playerView;

@end

@implementation SecondViewController
static NSString *uriString = @"http://flv2.bn.netease.com/videolib3/1609/11/gKWPF2934/SD/movie_index.m3u8";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createVideoView];
}

#pragma mark - 创建视频播放视图
- (void)createVideoView {
    self.playerView = [HHPlayerView sharedPlayerView];
    self.playerView.frame = CGRectMake(0, 20, kScreenWidth, 180 * kScreenWidth / 320.0);
    self.playerView.urlString = uriString;
    [self.view addSubview:self.playerView];
}


- (IBAction)btnClick:(id)sender {
    [self.playerView.player pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
