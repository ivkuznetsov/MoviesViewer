//
//  AMFailedView.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMFailedView.h"
#import "UIView+LoadingFromFrameworkNib.h"

@interface AMFailedView()

@property (nonatomic) dispatch_block_t retryBlock;

@end

@implementation AMFailedView

+ (instancetype)presentInView:(UIView*)view text:(NSString *)text retry:(dispatch_block_t)retry {
    AMFailedView *failedView = [self loadFromFrameworkNib];
    failedView.frame = view.bounds;
    failedView.textLabel.text = text;
    failedView.retryBlock = retry;
    [view addSubview:failedView];
    
    failedView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[failedView]|" options:0 metrics:nil views:@{@"failedView" : failedView}]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[failedView]|" options:0 metrics:nil views:@{@"failedView" : failedView}]];
    
    return failedView;
}

- (void)setRetryBlock:(dispatch_block_t)retryBlock {
    _retryBlock = retryBlock;
    _retryButton.hidden = retryBlock == nil;
}

- (IBAction)retryAction:(id)sender {
    if (_retryBlock) {
        _retryBlock();
    }
}

@end
