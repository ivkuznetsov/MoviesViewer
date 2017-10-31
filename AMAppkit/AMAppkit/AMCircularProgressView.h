//
//  AMCircularProgressView.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMCircularProgressView : UIView

@property (nonatomic) CGFloat progress;
@property (nonatomic) IBInspectable CGFloat lineWidth;
@property (nonatomic) IBInspectable UIColor *fillColor;

@end
