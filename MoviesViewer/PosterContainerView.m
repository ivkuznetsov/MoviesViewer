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
    self.layer.shadowRadius = 3.0;
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowOpacity = 0.15;
    self.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.05].CGColor;
    self.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
}

@end