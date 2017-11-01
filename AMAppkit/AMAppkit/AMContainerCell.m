//
//  AMContainerCell.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMContainerCell.h"

@implementation AMContainerCell

- (void)prepareForReuse {
    [super prepareForReuse];
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
}

@end
