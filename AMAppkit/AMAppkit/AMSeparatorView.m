//
//  AMSeparatorView.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 27/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMSeparatorView.h"

@interface AMSeparatorView ()

@property (nonatomic) UIColor *color;

@end

@implementation AMSeparatorView

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
    [super setBackgroundColor:[UIColor clearColor]];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (!_color) {
        _color = backgroundColor;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    [_color setStroke];
    
    CGFloat lineWidth = 1/[UIScreen mainScreen].scale;
    
    CGContextSetLineWidth(context, lineWidth);
    
    if (self.bounds.size.height == 1.0f) {
        CGFloat y = self.contentMode == UIViewContentModeTop ? lineWidth/2 : (self.bounds.size.height - lineWidth/2);
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, self.bounds.size.width, y);
    }
    else if (self.bounds.size.width == 1.0f) {
        CGFloat x = self.contentMode == UIViewContentModeRight ? (self.bounds.size.width - lineWidth/2) : lineWidth/2;
        CGContextMoveToPoint(context, x, 0);
        CGContextAddLineToPoint(context, x, self.bounds.size.height);
    }
    CGContextStrokePath(context);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

@end
