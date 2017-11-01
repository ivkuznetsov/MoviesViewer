//
//  AMLoadingBarView.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMLoadingBarView : UIView

@property (nonatomic) BOOL infinite;
@property (nonatomic) CGFloat progress;
@property (nonatomic) UIColor *fillColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *clipColor UI_APPEARANCE_SELECTOR;

+ (instancetype)presentInView:(UIView *)view animated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

@end
