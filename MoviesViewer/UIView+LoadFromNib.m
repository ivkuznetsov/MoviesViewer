//
//  UIView+LoadFromNib.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "UIView+LoadFromNib.h"
#import "NSObject+ClassName.h"

@implementation UIView (LoadFromNib)

+ (instancetype)loadFromNib {
    return [self loadFromNib:[self className]];
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

@end