//
//  AMOperationHelper.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMOperationHelper.h"
#import "AMFailedView.h"
#import "AMLoadingView.h"
#import "AMLoadingBarView.h"
#import "AMAlertBarView.h"

@interface AMOperationHelper() {
    NSUInteger _loadingCounter;
    NSUInteger _touchableLoadingCounter;
}

@property (nonatomic, weak) UIView *view;
@property (nonatomic) NSMutableDictionary *operations;
@property (nonatomic, weak) AMFailedView *failedView;
@property (nonatomic, weak) AMLoadingView *loadingView;
@property (nonatomic, weak) AMLoadingBarView *loadingBarView;
@property (nonatomic, weak) AMAlertBarView *alertBarView;

@end

@implementation AMOperationHelper

- (instancetype)initWithView:(UIView *)view {
    if (self = [super init]) {
        _view = view;
        _operations = [NSMutableDictionary dictionary];
        
        if (!self.loadingViewClass) {
            self.loadingViewClass = [AMLoadingView class];
        }
        if (!self.loadingBarViewClass) {
            self.loadingBarViewClass = [AMLoadingBarView class];
        }
        if (!self.failedViewClass) {
            self.failedViewClass = [AMFailedView class];
        }
        if (!self.failedBarViewClass) {
            self.failedBarViewClass = [AMAlertBarView class];
        }
    }
    return self;
}

- (void)runBlock:(void(^)(AMCompletion, AMHandleOperation, AMProgress))block
      completion:(AMCompletion)completion
         loading:(AMLoadingType)loadingType
             key:(NSString *)key {
    
    if (!_processTranslucentError && loadingType == AMLoadingTypeTranslucent) {
        [NSException raise:@"AMOperationHelper" format:@"_processTranslucentError block must be set to use AMLoadingTypeTranslucent"];
    }
    
    if (key) {
        NSOperation *operation = _operations[key];
        [operation cancel];
        _operations[key] = nil;
    }
    [self incrementLoading:loadingType];
    
    if (loadingType == AMLoadingTypeFullscreen || loadingType == AMLoadingTypeTranslucent) {
        [_failedView removeFromSuperview];
    }
    
    __weak typeof(self)weakSelf = self;
    block(^(id request, NSError *error) {
        [weakSelf decrementLoading:loadingType];
        
        dispatch_block_t retryBlock = nil;
        if (!weakSelf.shouldSupplyRetry || weakSelf.shouldSupplyRetry(request, error)) {
            retryBlock = ^{
                [weakSelf runBlock:block completion:completion loading:loadingType key:key];
            };
        }
        [weakSelf processError:error retryBlock:retryBlock loadingType:loadingType];
        if (completion) {
            completion(request, error);
        }
    }, ^(id operation) {
        if (operation) {
            NSString *saveKey = key;
            if (!saveKey) {
                saveKey = [NSUUID UUID].UUIDString;
            }
            weakSelf.operations[saveKey] = operation;
        }
    }, ^(CGFloat progress) {
        if (loadingType == AMLoadingTypeFullscreen || loadingType == AMLoadingTypeTranslucent) {
            weakSelf.loadingView.progress = progress;
        } else if (loadingType == AMLoadingTypeTouchable) {
            weakSelf.loadingBarView.progress = progress;
        }
    });
}

- (void)processError:(NSError *)error retryBlock:(dispatch_block_t)retryBlock loadingType:(AMLoadingType)loadingType {
    if (!error || error.code == NSURLErrorCancelled) {
        return;
    }
    
    if (loadingType == AMLoadingTypeTranslucent) {
        _processTranslucentError(error, retryBlock);
    } else if (loadingType == AMLoadingTypeFullscreen) {
        _failedView = [self.failedViewClass presentInView:self.view text:error.localizedDescription retry:retryBlock];
    } else if (loadingType == AMLoadingTypeTouchable) {
        if (!_alertBarView || ![_alertBarView.message isEqualToString:error.localizedDescription]) {
            _alertBarView = [self.failedBarViewClass presentInView:self.view message:error.localizedDescription];
        }
    }
}

- (void)incrementLoading:(AMLoadingType)type {
    if (type == AMLoadingTypeTranslucent || type == AMLoadingTypeFullscreen) {
        if (_loadingCounter == 0) {
            _loadingView = [self.loadingViewClass presentInView:self.view animated:(type == AMLoadingTypeTranslucent) && self.view.window != nil && !self.failedView.superview];
        }
        if (type == AMLoadingTypeFullscreen && !_loadingView.opaqueStyle) {
            _loadingView.opaqueStyle = YES;
        }
        _loadingCounter++;
    } else if (type == AMLoadingTypeTouchable) {
        if (_touchableLoadingCounter == 0) {
            _loadingBarView = [self.loadingBarViewClass presentInView:self.view animated:YES];
        }
        _touchableLoadingCounter++;
    }
}

- (void)decrementLoading:(AMLoadingType)type {
    if (type == AMLoadingTypeTranslucent || type == AMLoadingTypeFullscreen) {
        _loadingCounter--;
        if (_loadingCounter == 0) {
            [_loadingView hideAnimated:YES];
        }
    } else if (type == AMLoadingTypeTouchable) {
        _touchableLoadingCounter--;
        if (_touchableLoadingCounter == 0) {
            [_loadingBarView hideAnimated:YES];
        }
    }
}

- (void)cancellOperations {
    for (NSOperation *operation in [_operations allValues]) {
        [operation cancel];
    }
}

- (void)dealloc {
    [self cancellOperations];
}

@end
