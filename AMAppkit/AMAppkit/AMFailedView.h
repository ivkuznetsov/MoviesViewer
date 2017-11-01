//
//  AMFailedView.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBorderedButton.h"

@interface AMFailedView : UIView

@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet AMBorderedButton *retryButton;

+ (instancetype)presentInView:(UIView*)view text:(NSString *)text retry:(dispatch_block_t)retry;

@end
