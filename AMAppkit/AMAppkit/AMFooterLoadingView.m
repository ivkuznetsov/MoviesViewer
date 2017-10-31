//
//  AMFooterLoadingView.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 05/02/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMFooterLoadingView.h"

@interface AMFooterLoadingView()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) IBOutlet UIButton *retryButton;

@end

@implementation AMFooterLoadingView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.state = AMFooterStateStop;
}

- (void)setState:(AMFooterState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    if (state == AMFooterStateStop) {
        [_indicatorView stopAnimating];
        _retryButton.hidden = YES;
    } else if (state == AMFooterStateLoading) {
        [_indicatorView startAnimating];
        _retryButton.hidden = YES;
    } else if (state == AMFooterStateFailed) {
        [_indicatorView stopAnimating];
        _retryButton.hidden = NO;
    }
}

- (IBAction)retryAction:(id)sender {
    if (_retryAction) {
        _retryAction();
    }
}

@end
