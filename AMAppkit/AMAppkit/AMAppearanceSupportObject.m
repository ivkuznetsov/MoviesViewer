//
//  AMAppearanceSupportObject.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 29/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMAppearanceSupportObject.h"
#import "AMAppearance.h"

@implementation AMAppearanceSupportObject

- (instancetype)init {
    if (self = [super init]) {
        [[AMAppearance appearanceForClass:[self class]] startForwarding:self];
    }
    return self;
}

+ (instancetype)appearance {
    return (AMAppearanceSupportObject *)[AMAppearance appearanceForClass:[self class]];
}

@end
