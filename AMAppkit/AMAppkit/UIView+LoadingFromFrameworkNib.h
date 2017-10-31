//
//  UIView+LoadingFromFrameworkNib.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LoadingFromFrameworkNib)

+ (instancetype)loadFromNib;
+ (instancetype)loadFromNib:(NSString *)nibName;
+ (instancetype)loadFromNib:(NSString *)nibName withOwner:(id)owner;

+ (instancetype)loadFromFrameworkNib;
+ (instancetype)loadFromFrameworkNib:(NSString *)nibName;
+ (instancetype)loadFromFrameworkNib:(NSString *)nibName withOwner:(id)owner;

@end
