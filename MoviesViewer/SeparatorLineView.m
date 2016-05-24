//
//  SeparatorLineView.m
//  WorldBank
//
//  Created by Ilya Kuznecov on 31/03/16.
//  Copyright © 2016 Arello Mobile. All rights reserved.
//

#import "SeparatorLineView.h"

@implementation SeparatorLineView

- (void)awakeFromNib {
    UIView *view = [UIView new];
    view.backgroundColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:view];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIView *view = self.subviews.firstObject;
    CGFloat height = 1.0 / [UIScreen mainScreen].scale;
    
    if (self.contentMode == UIViewContentModeTop) {
        view.frame = CGRectMake(0, 0, self.width, height);
    } else if (self.contentMode == UIViewContentModeBottom) {
        view.frame = CGRectMake(0, self.height - height, self.width, height);
    } else if (self.contentMode == UIViewContentModeLeft) {
        view.frame = CGRectMake(0, 0, height, self.height);
    } else if (self.contentMode == UIViewContentModeRight) {
        view.frame = CGRectMake(0, self.width - height, height, self.height);
    }
}

@end
