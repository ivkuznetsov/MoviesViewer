//
//  AMAlertBarView.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMAlertBarView.h"
#import <UIView+LoadingFromFrameworkNib.h>

@interface AMAlertBarView()

@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@end

@implementation AMAlertBarView

+ (instancetype)presentInView:(UIView *)view message:(NSString *)message {
    AMAlertBarView *barView = [AMAlertBarView loadFromFrameworkNib];
    [view addSubview:barView];
    barView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[barView]|" options:0 metrics:nil views:@{@"barView" : barView}]];
    
    UIViewController *vc = (UIViewController *)view.nextResponder;
    if ([vc isKindOfClass:[UIViewController class]]) {
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide][barView]" options:0 metrics:nil views:@{@"barView" : barView, @"topLayoutGuide" : vc.topLayoutGuide}]];
    } else {
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[barView]" options:0 metrics:nil views:@{@"barView" : barView}]];
    }
    
    barView.textLabel.text = message;
    barView.alpha = 0.0;
    barView.textLabel.superview.transform = CGAffineTransformMakeTranslation(0, -barView.bounds.size.height);
    [UIView animateWithDuration:0.25 animations:^{
        barView.textLabel.superview.transform = CGAffineTransformIdentity;
        barView.alpha = 1.0;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [barView hide];
    });
    return barView;
}

- (NSString *)message {
    return _textLabel.text;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _textLabel.superview.layer.cornerRadius = 6.0;
}

- (void)hide {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
