//
//  AMFadeButton.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 27/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMFadeButton.h"

@implementation AMFadeButton

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.alpha = 0.5;
    } else if (self.enabled) {
        self.alpha = 1.0;
        
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionFade;
        transition.duration = 0.15;
        [self.layer addAnimation:transition forKey:nil];
        [_additionalView.layer addAnimation:transition forKey:nil];
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        self.alpha = self.highlighted ? 0.5 : 1.0;
    } else {
        self.alpha = 0.5;
    }
}

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    _additionalView.alpha = alpha;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    _additionalView.hidden = hidden;
}

@end
