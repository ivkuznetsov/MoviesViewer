//
//  AMLoadingView.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMLoadingView.h"
#import "UIView+LoadingFromFrameworkNib.h"

@implementation AMLoadingView

+ (instancetype)presentInView:(UIView *)view animated:(BOOL)animated {
    AMLoadingView *loadingView = [self loadFromFrameworkNib];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    loadingView.frame = view.bounds;
    loadingView.progressIndicator.hidden = YES;
    loadingView.opaqueStyle = NO;
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

- (void)setOpaqueStyle:(BOOL)opaqueStyle {
    _opaqueStyle = opaqueStyle;
    self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:_opaqueStyle ? 1.0 : 0.6];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    _indicator.hidden = YES;
    _progressIndicator.hidden = NO;
    _progressIndicator.progress = progress;
}

@end
