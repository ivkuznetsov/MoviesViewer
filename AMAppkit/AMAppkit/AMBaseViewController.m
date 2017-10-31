//
//  AMBaseViewController.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMBaseViewController.h"

@implementation AMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.navigationController.presentingViewController) {
        NSArray *controllers = self.navigationController.viewControllers;
        NSUInteger index = [controllers indexOfObject:self];
        
        if (index != NSNotFound) {
            if (index == 0 || [controllers[index - 1] navigationItem].rightBarButtonItem.action == @selector(closeAction)) {
                [self createCloseButton];
            }
        }
    }
}

- (void)createCloseButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(closeAction)];
}

- (UIViewController *)previousViewController {
    NSArray *array = self.navigationController.viewControllers;
    
    NSUInteger index = [array indexOfObject:self];
    if (index == NSNotFound || index == 0) {
        return nil;
    }
    return array[[array indexOfObject:self] - 1];
}

- (IBAction)closeAction {
    if (!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if (self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if (self.parentViewController.navigationController.presentingViewController) {
        [self.parentViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)reloadView:(BOOL)animated {
}

@end
