//
//  AMBorderedButton.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 27/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMBorderedButton.h"

@implementation AMBorderedButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.cornerRadius = 8;
    self.borderColor = [self titleColorForState:UIControlStateNormal];
}

- (UIColor *)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self reloadBorder];
}

- (void)setOneScreenPixelWidth:(BOOL)oneScreenPixelWidth {
    _oneScreenPixelWidth = oneScreenPixelWidth;
    [self reloadBorder];
}

- (void)reloadBorder {
    if (_oneScreenPixelWidth) {
        self.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    } else {
        self.layer.borderWidth = _borderWidth;
    }
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

@end
