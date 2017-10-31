//
//  UIView+LoadingFromFrameworkNib.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "UIView+LoadingFromFrameworkNib.h"

@implementation UIView (LoadingFromFrameworkNib)

+ (instancetype)loadFromNib {
    return [self loadFromNib:NSStringFromClass(self)];
}

+ (instancetype)loadFromNib:(NSString *)nibName {
    return [self loadFromNib:nibName withOwner:nil];
}

+ (instancetype)loadFromNib:(NSString *)nibName withOwner:(id)owner {
    NSArray *loadedObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:nil];
    for (id obj in loadedObjects) {
        if ([obj isKindOfClass:self]) {
            return obj;
        }
    }
    return nil;
}

+ (instancetype)loadFromFrameworkNib {
    return [self loadFromFrameworkNib:NSStringFromClass(self)];
}

+ (instancetype)loadFromFrameworkNib:(NSString *)nibName {
    return [self loadFromFrameworkNib:nibName withOwner:nil];
}

+ (instancetype)loadFromFrameworkNib:(NSString *)nibName withOwner:(id)owner {
    NSBundle *bundle = [NSBundle mainBundle];
    if ([bundle pathForResource:nibName ofType:@"nib"] == nil) {
        bundle = [NSBundle bundleForClass:self];
    }
    NSArray *loadedObjects = [bundle loadNibNamed:nibName owner:owner options:nil];
    for (id obj in loadedObjects) {
        if ([obj isKindOfClass:self]) {
            return obj;
        }
    }
    return nil;
}

@end
