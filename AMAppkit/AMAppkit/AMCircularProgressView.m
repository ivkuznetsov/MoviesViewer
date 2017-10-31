//
//  AMCircularProgressView.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMCircularProgressView.h"

@interface AMCircularProgressView()

@property (nonatomic) CAShapeLayer *bgLayer;
@property (nonatomic) CAShapeLayer *progressLayer;

@end

@implementation AMCircularProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self.layer addSublayer:self.bgLayer];
    [self.layer addSublayer:self.progressLayer];
}

- (CAShapeLayer *)bgLayer {
    if (!_bgLayer) {
        _bgLayer = [CAShapeLayer layer];
        _bgLayer.strokeColor = _fillColor.CGColor;
        _bgLayer.lineWidth = _lineWidth;
        _bgLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _bgLayer;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = self.tintColor.CGColor;
        _progressLayer.lineWidth = _lineWidth;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeEnd = 0.0;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _progressLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.progressLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    self.bgLayer.frame = _progressLayer.frame;
    [self updatePath];
}

- (void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - self.progressLayer.lineWidth / 2;
    CGFloat startAngle = (CGFloat)(-M_PI_2);
    CGFloat endAngle = (CGFloat)(3 * M_PI_2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.progressLayer.path = path.CGPath;
    self.bgLayer.path = path.CGPath;
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.bgLayer.strokeColor = fillColor.CGColor;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    self.progressLayer.lineWidth = lineWidth;
    self.bgLayer.lineWidth = lineWidth;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.progressLayer.strokeEnd = progress;
}

@end
