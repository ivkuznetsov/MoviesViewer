//
//  ContainerCell.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "ContainerCell.h"

@implementation ContainerCell

- (void)prepareForReuse {
    [super prepareForReuse];
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)attachView:(UIView *)view {
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.frame = CGRectMake(0, 0, self.contentView.width, self.contentView.height);
    [self.contentView addSubview:view];
}

@end
