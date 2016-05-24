//
//  BaseViewController.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseNavigationController.h"
#import "LoadingView.h"
#import "FailedView.h"

@interface BaseViewController ()

@property (nonatomic, weak) FailedView *failedView;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	if (self.navigationController.presentingViewController) {
        [self createCloseButton];
    }
}

- (void)createCloseButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(closeAction)];
}

- (IBAction)closeAction {
    if (!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)runBlock:(void(^)(CompletionBlock, HandleOperation))block
      completion:(CompletionBlock)completion
         loading:(LoadingType)loadingType
       errorType:(ErrorType)errorType {
    
    [self.view endEditing:YES];
    
    [_failedView removeFromSuperview];
    
    LoadingView *loadingView = nil;
    if (loadingType != LoadingTypeNone) {
        loadingView = [LoadingView presentInView:self.view animated:NO];
    }
    loadingView.translucent = loadingType == LoadingTypeTranslucent;
    
    __weak typeof(self) weakSelf = self;
    block(^(id request, NSError *error){
        [loadingView hideAnimated:YES];
        if (error) {
            [weakSelf processError:error errorType:errorType];
        }
        if (completion) {
            completion(request, error);
        }
    }, ^(NSOperation *operation){
        weakSelf.currentOperation = operation;
    });
}

- (void)processError:(NSError *)error errorType:(ErrorType)errorType {
    if (error.code == NSURLErrorCancelled) {
        NSLog(@"cancelled");
        return;
    }
    
    if (errorType == ErrorTypeAlert) {
        [AlertView alertWithMessage:error.localizedDescription];
    } else if (errorType == ErrorTypeFull) {
        [self showFullscreenError:error.localizedDescription];
    } else if (errorType == ErrorTypeBanner) {
        
    }
}

- (void)showFullscreenError:(NSString *)string {
    [_failedView removeFromSuperview];
    _failedView = [FailedView presentInView:self.view withText:string];
}

- (void)dealloc {
    [_currentOperation cancel];
}

@end