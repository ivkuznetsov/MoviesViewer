//
//  AMLoadingBarView.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMLoadingBarView.h"

@interface AMLoadingBarView()

@property (nonatomic) CAShapeLayer *fillLayer;
@property (nonatomic) CAShapeLayer *clipLayer;

@end

@implementation AMLoadingBarView

+ (instancetype)presentInView:(UIView *)view animated:(BOOL)animated {
    AMLoadingBarView *barView = [[AMLoadingBarView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 3)];
    [view addSubview:barView];
    
    UIViewController *vc = (UIViewController *)view.nextResponder;
    if ([vc isKindOfClass:[UIViewController class]]) {
        barView.translatesAutoresizingMaskIntoConstraints = NO;
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[barView]|" options:0 metrics:nil views:@{@"barView" : barView}]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide][barView(3)]" options:0 metrics:nil views:@{@"barView" : barView, @"topLayoutGuide" : vc.topLayoutGuide}]];
    } else {
        barView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    if (!barView.fillColor) {
        barView.fillColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0];
    }
    if (!barView.clipColor) {
        barView.clipColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    }
    if (animated) {
        barView.alpha = 0.0;
        [UIView animateWithDuration:0.15 animations:^{
            barView.alpha = 1.0;
        }];
    }
    barView.infinite = YES;
    return barView;
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

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.fillLayer.strokeColor = fillColor.CGColor;
}

- (void)setClipColor:(UIColor *)clipColor {
    _clipColor = clipColor;
    self.clipLayer.strokeColor = clipColor.CGColor;
}

- (CAShapeLayer *)fillLayer {
    if (!_fillLayer) {
        _fillLayer = [CAShapeLayer layer];
        _fillLayer.strokeColor = _fillColor.CGColor;
        _fillLayer.lineCap = kCALineCapRound;
        _fillLayer.fillColor = [UIColor clearColor].CGColor;
        _fillLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.05].CGColor;
        [self.layer addSublayer:_fillLayer];
    }
    return _fillLayer;
}

- (CAShapeLayer *)clipLayer {
    if (!_clipLayer) {
        _clipLayer = [CAShapeLayer layer];
        _clipLayer.strokeColor = self.tintColor.CGColor;
        _clipLayer.fillColor = [UIColor clearColor].CGColor;
        _clipLayer.lineCap = kCALineCapRound;
        [self.fillLayer addSublayer:_clipLayer];
    }
    return _clipLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _fillLayer.frame = self.bounds;
    _clipLayer.frame = _fillLayer.bounds;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.bounds.size.height / 2.0)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height / 2.0)];
    _fillLayer.path = path.CGPath;
    _fillLayer.lineWidth = self.bounds.size.height;
    _clipLayer.lineWidth = self.bounds.size.height;
    
    _clipLayer.path = [self startPath];
}

- (CGPathRef)startPath {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.bounds.size.height / 2.0)];
    
    CGFloat offset = -16;
    
    while (offset < self.bounds.size.width) {
        [path moveToPoint:CGPointMake(offset, self.bounds.size.height / 2.0)];
        [path addLineToPoint:CGPointMake(offset + 6, self.bounds.size.height / 2.0)];
        offset += 16;
    };
    return path.CGPath;
}

- (CGPathRef)toPath {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.bounds.size.height / 2.0)];
    
    CGFloat offset = 0;
    
    while (offset < self.bounds.size.width + 16) {
        [path moveToPoint:CGPointMake(offset, self.bounds.size.height / 2.0)];
        [path addLineToPoint:CGPointMake(offset + 6, self.bounds.size.height / 2.0)];
        offset += 16;
    };
    return path.CGPath;
}

- (void)startAnimation {
    if ([_clipLayer animationForKey:@"animation"]) {
        return;
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (id)[self startPath];
    animation.toValue = (id)[self toPath];
    animation.duration = 0.2;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.repeatCount = HUGE_VALF;
    [_clipLayer addAnimation:animation forKey:@"animation"];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview && _infinite) {
        [self startAnimation];
    } else {
        [_clipLayer removeAllAnimations];
    }
}

- (void)setInfinite:(BOOL)infinite {
    _infinite = infinite;
    _clipLayer.hidden = !infinite;
    if (infinite) {
        [self startAnimation];
    } else {
        [_clipLayer removeAllAnimations];
    }
}

- (void)setProgress:(CGFloat)progress {
    CGFloat oldProgress = _progress;
    _progress = progress;
    self.infinite = NO;
    _fillLayer.strokeEnd = progress;
    if (_progress <= oldProgress) {
        [_fillLayer removeAnimationForKey:@"strokeEnd"];
    }
}

@end
