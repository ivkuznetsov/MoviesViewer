//
//  AMCollectionView.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMCollectionView.h"

@interface AMCollectionView()

@property (nonatomic) NSMutableSet *registeredCells;

@end

@implementation AMCollectionView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _registeredCells = [NSMutableSet set];
        self.canCancelContentTouches = YES;
        self.delaysContentTouches = NO;
    }
    return self;
}

- (UICollectionViewCell *)createCellForClass:(Class)cellClass indexPath:(NSIndexPath *)indexPath {
    if (![_registeredCells containsObject:cellClass]) {
        [self registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:[NSBundle bundleForClass:cellClass]] forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
        [_registeredCells addObject:cellClass];
    }
    return [self dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end
