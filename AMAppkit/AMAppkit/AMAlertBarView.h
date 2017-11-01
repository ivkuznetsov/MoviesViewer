//
//  AMAlertBarView.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMAlertBarView : UIView

+ (instancetype)presentInView:(UIView *)view message:(NSString *)message;
- (NSString *)message;

@end
