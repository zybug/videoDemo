//
//  HHPlayerView.m
//  VideoDemo
//
//  Created by localadmin on 16/9/9.
//  Copyright © 2016年 searainbow. All rights reserved.
//

#import "HHPlayerView.h"
#import "HHFullPlayerViewController.h"

@interface HHPlayerView ()
{
    CGRect _currentRectInContrainerVC;
}

@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, weak) AVPlayerLayer *playerLayer; // 播放器的Layer
@property (nonatomic, assign) BOOL isShowToolsView; // 是否显示工具栏

@property (nonatomic, strong) NSString *videoOverTime; // 视频全长时间
@property (nonatomic, strong) NSString *videoPlayTime; // 视频播放时间
@property (nonatomic, strong) CADisplayLink *progressDisplayTimer; // 更新进度条

#pragma mark - IB
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView; // 主layer 显示
@property (weak, nonatomic) IBOutlet UISlider *progressSlider; // 进度条
@property (weak, nonatomic) IBOutlet UILabel *timeLabel; // 显示时间
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton; // 是否全屏按钮
@property (weak, nonatomic) IBOutlet UIView *toolsView; // 工具栏
@property (weak, nonatomic) IBOutlet UIImageView *backImageView; // 向左的图片
@property (weak, nonatomic) IBOutlet UIImageView *forwardImageView; // 向右的图片
//@property (nonatomic, strong) UIImageView *loadingImageView; // 加载动画

@end

@implementation HHPlayerView
static HHPlayerView *_hhPlayerView;

#pragma mark - lazy load

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (void)awakeFromNib {
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.bgImageView.layer addSublayer:self.playerLayer];
    self.bgImageView.userInteractionEnabled = YES;
    self.backImageView.alpha = 0.0;
    self.forwardImageView.alpha = 0.0;
    
    // 设置Slider
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"thumbImage"] forState:UIControlStateNormal];
    [self.progressSlider setMaximumTrackImage:[UIImage imageNamed:@"MaximumTrackImage"] forState:UIControlStateNormal];
    [self.progressSlider setMinimumTrackImage:[UIImage imageNamed:@"MinimumTrackImage"] forState:UIControlStateNormal];
    [self.progressSlider addTarget:self action:@selector(changeSliderValue:) forControlEvents:UIControlEventValueChanged];
    
    self.isShowToolsView = NO;
}

- (HHFullPlayerViewController *)fullViewController {
    if (!_fullViewController) {
        _fullViewController = [[HHFullPlayerViewController alloc] init];
    }
    return _fullViewController;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (AVPlayerItemStatusReadyToPlay == status) {
            // 获取视频长度时间
            self.videoOverTime = [self changeTime:CMTimeGetSeconds(self.player.currentItem.duration)];
            [self addProgressDisplayTimer];
            
            self.playOrPauseButton.enabled = YES;
            self.progressSlider.enabled = YES;
        } else {
            
        }
    }
}

#pragma mark - 更新进度条
// 添加进度条定时器
- (void)addProgressDisplayTimer {
    self.progressDisplayTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgressInfo)];
    [self.progressDisplayTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeProgressDisplayTimer {
    [self.progressDisplayTimer invalidate];
    self.progressDisplayTimer = nil;
}

// 更新进度条
- (void)updateProgressInfo {
    // 更新显示的时间
    self.videoPlayTime = [self changeTime:CMTimeGetSeconds(self.player.currentTime)];
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@", self.videoPlayTime, self.videoOverTime];
    
    // 更新进度条
    self.progressSlider.value = CMTimeGetSeconds(self.player.currentTime) / CMTimeGetSeconds(self.player.currentItem.duration);
}

// 手动拖动Slider
- (void)changeSliderValue:(UISlider *)slider {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * slider.value;
    [self changePlayerTime:currentTime];
}

// 修改播放时间进度
- (void)changePlayerTime:(NSTimeInterval)timeInterval {
    [self.player seekToTime:CMTimeMakeWithSeconds(timeInterval, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - 手势
// 显示工具条
- (IBAction)touchViewShowTools:(UITapGestureRecognizer *)sender {
    self.isShowToolsView = !self.isShowToolsView;
    [self showToolsView:self.isShowToolsView];
}
// 向左滑动
- (IBAction)swipeToLeft:(UISwipeGestureRecognizer *)sender {
    [self swipeChangeVideoTime:YES];
}
// 向右滑动
- (IBAction)swipeToRight:(UISwipeGestureRecognizer *)sender {
    [self swipeChangeVideoTime:NO];
}
// 滑动修改播放时间
- (void)swipeChangeVideoTime:(BOOL)leftDirection{
    // 获取当前播放的时间
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
    if (leftDirection) {
        [UIView animateWithDuration:1 animations:^{
            self.backImageView.alpha = 1;
        } completion:^(BOOL finished) {
            self.backImageView.alpha = 0;
        }];
        currentTime -= 10;
    } else {
        [UIView animateWithDuration:1 animations:^{
            self.forwardImageView.alpha = 1;
        } completion:^(BOOL finished) {
            self.forwardImageView.alpha = 0;
        }];
        currentTime += 10;
    }
    if (currentTime >= CMTimeGetSeconds(self.player.currentItem.duration)) {
        currentTime = CMTimeGetSeconds(self.player.currentItem.duration) - 1;
    } else if (currentTime <= 0) {
        currentTime = 0;
    }
    [self changePlayerTime:currentTime];
}

#pragma mark - public
+ (instancetype)sharedPlayerView {
    @synchronized (self) {
        _hhPlayerView = [[[NSBundle mainBundle] loadNibNamed:@"HHPlayerView" owner:nil options:nil] firstObject];
    }
    return _hhPlayerView;
}

- (void)showToolsView:(BOOL)isShow {
    if (self.isShowToolsView) {
        [UIView animateWithDuration:0.5 animations:^{
            self.toolsView.alpha = 1.0;
            self.toolsView.hidden = NO;
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.toolsView.alpha = 0.0;
            self.toolsView.hidden = YES;
        }];
    }
}

// 设置播放地址
- (void)setUrlString:(NSString *)urlString {
    _urlString = urlString;
    self.isShowToolsView = YES;
    self.toolsView.hidden = NO;
    self.playOrPauseButton.enabled = NO;
    self.progressSlider.enabled = NO;
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    self.currentItem = item;
    
    [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
    [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // 视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
    
}

- (void)moviePlayDidEnd:(NSNotification *)not {
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.progressSlider setValue:0.0 animated:YES];
        weakSelf.playOrPauseButton.selected = NO;
    }];
}

// 播放或暂停按钮
- (IBAction)playOrPauseClick:(UIButton *)sender {
//    if (self.player.status != AVPlayerItemStatusReadyToPlay) {
//        // 如果视频没有连接上，或者不能播放直接返回
//        return;
//    }
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player play];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self touchViewShowTools:nil]; // 10s自动隐藏播放器
        });
    } else {
        [self.player pause];
    }
}
// 是否全屏
- (IBAction)fullScreenOrNotClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        // 切换到全屏
        self.contrainerViewController = [self hh_getParentViewController:self];
        _currentRectInContrainerVC = [self.contrainerViewController.view convertRect:self.frame toView:self.contrainerViewController.view];
        [self.contrainerViewController presentViewController:self.fullViewController animated:NO completion:^{
            [self.fullViewController.view addSubview:self];
            self.center = self.fullViewController.view.center;
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                self.frame = self.fullViewController.view.bounds;
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self touchViewShowTools:nil];
                });
            }];
        }];
    } else {
        [self.fullViewController dismissViewControllerAnimated:YES completion:^{
            [self.contrainerViewController.view addSubview:self];
            [UIView animateWithDuration:0.3 animations:^{
                self.frame = _currentRectInContrainerVC;
            }];
        }];
    }
}


#pragma mark - Helper
- (UIViewController *)hh_getParentViewController:(UIView *)view {
    id target=view;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

// 转换时间变成00:00 格式
- (NSString *)changeTime:(NSTimeInterval)timeInterval {
    NSInteger dMin = timeInterval / 60;
    NSInteger dSec = (NSInteger)timeInterval % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)dMin, (long)dSec];
}

- (void)dealloc {
    NSLog(@"Player dealloc");
    [self.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    if (self.progressDisplayTimer) {
        [self.progressDisplayTimer invalidate];
        self.progressDisplayTimer = nil;
    }
}


@end
