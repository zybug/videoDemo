//
//  HHFullPlayerView.m
//  VideoDemo
//
//  Created by localadmin on 16/9/9.
//  Copyright © 2016年 searainbow. All rights reserved.
//

#import "HHFullPlayerView.h"

@implementation HHFullPlayerView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.autoresizesSubviews = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

@end
