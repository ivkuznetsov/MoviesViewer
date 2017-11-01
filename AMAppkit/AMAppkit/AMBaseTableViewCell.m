//
//  AMBaseTableViewCell.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMBaseTableViewCell.h"

@implementation AMBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.1];
}

- (void)setHiddenSeparator:(BOOL)hiddenSeparator {
    _hiddenSeparator = hiddenSeparator;
    [self setSeparatorHidden:_hiddenSeparator];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setSeparatorHidden:_hiddenSeparator];
}

- (void)setSeparatorHidden:(BOOL)hidden {
    for (UIView *subview in self.contentView.superview.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"SeparatorView"]) {
            subview.hidden = hidden;
            subview.alpha = !hidden;
        }
    }
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

@end
