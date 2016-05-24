//
//  UIView+Transitions.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "UIView+Transitions.h"

@implementation UIView (Transitions)

- (void)addFadeTransition {
    [self addFadeTransitionWithDuration:0.15f];
}

- (void)addFadeTransitionWithDuration:(float)duration {
    if ([self.layer animationForKey:@"fade"]) {
        return;
    }
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = duration;
    [self.layer addAnimation:transition forKey:@"fade"];
}

@end