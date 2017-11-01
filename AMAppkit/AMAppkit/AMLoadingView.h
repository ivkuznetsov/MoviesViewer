//
//  AMLoadingView.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMCircularProgressView.h"

@interface AMLoadingView : UIView

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet AMCircularProgressView *progressIndicator;
@property (nonatomic) BOOL opaqueStyle;
@property (nonatomic) CGFloat progress;

+ (instancetype)presentInView:(UIView *)view animated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

@end
