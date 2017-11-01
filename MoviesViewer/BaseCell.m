//
//  BaseCell.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "BaseCell.h"

@implementation BaseCell

- (void)highlihtCell {
    self.alpha = 0.7;
    self.transform = CGAffineTransformMakeScale(0.95, 0.95);
}

- (void)unhighlightCell {
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 1.0;
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        [self highlihtCell];
    } else {
        [self unhighlightCell];
    }
}

@end
