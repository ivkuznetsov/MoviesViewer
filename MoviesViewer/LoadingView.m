//
//  LoadingView.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "LoadingView.h"
#import "UIView+LoadFromNib.h"

@implementation LoadingView

+ (instancetype)presentInView:(UIView *)view animated:(BOOL)animated {
    LoadingView *loadingView = [LoadingView loadFromNib];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    loadingView.frame = view.bounds;
    [view addSubview:loadingView];
    
    if (animated) {
        loadingView.alpha = 0.0;
        [UIView animateWithDuration:0.2 animations:^{
            loadingView.alpha = 1.0;
        }];
    }
    return loadingView;
}

- (void)hideAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
}

- (void)setTranslucent:(BOOL)translucent {
    _translucent = translucent;
    self.backgroundColor = _translucent ? [UIColor colorWithWhite:1 alpha:0.7] : [UIColor whiteColor];
}

@end
