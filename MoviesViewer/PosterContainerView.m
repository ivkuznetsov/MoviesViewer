//
//  PosterContainerView.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "PosterContainerView.h"

@implementation PosterContainerView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.shadowRadius = 3.0;
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowOpacity = 0.15;
    self.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.05].CGColor;
    self.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [self updateShadow];
}

- (void)updateShadow {
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.layer.bounds].CGPath;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateShadow];
}

@end
