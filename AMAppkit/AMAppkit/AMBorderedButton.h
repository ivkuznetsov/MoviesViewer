//
//  AMBorderedButton.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 27/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMFadeButton.h"

IB_DESIGNABLE
@interface AMBorderedButton : AMFadeButton

@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable BOOL oneScreenPixelWidth;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable CGFloat cornerRadius;

@end
