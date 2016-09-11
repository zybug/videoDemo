//
//  HHFullPlayerViewController.m
//  VideoDemo
//
//  Created by localadmin on 16/9/9.
//  Copyright © 2016年 searainbow. All rights reserved.
//

#import "HHFullPlayerViewController.h"
#import "HHFullPlayerView.h"

@interface HHFullPlayerViewController ()

@end

@implementation HHFullPlayerViewController

- (void)loadView
{
    HHFullPlayerView *fullView = [[HHFullPlayerView alloc] init];
    self.view = fullView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
