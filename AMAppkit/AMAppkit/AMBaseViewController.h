//
//  AMBaseViewController.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMOperationHelper.h"

@interface AMBaseViewController : UIViewController

// you have to create this object manually in subclass if you need it
@property (nonatomic) AMOperationHelper *operationHelper;

- (IBAction)closeAction;
- (UIViewController *)previousViewController;

//for overriding in subclasses
- (void)reloadView:(BOOL)animated;

@end
