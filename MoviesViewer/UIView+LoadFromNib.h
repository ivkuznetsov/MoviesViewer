//
//  UIView+LoadFromNib.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LoadFromNib)

+ (instancetype)loadFromNib;
+ (instancetype)loadFromNib:(NSString *)nibName;
+ (instancetype)loadFromNib:(NSString *)nibName withOwner:(id)owner;

@end
