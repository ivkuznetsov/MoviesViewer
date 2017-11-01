//
//  UICollectionView+Additions.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "UICollectionView+Additions.h"
#import <objc/runtime.h>

#define kCollecitonViewKey @"kCollecitonViewKey"

@implementation UICollectionView (Additions)

- (UICollectionViewCell *)createCellWithCellClass:(Class)cellClass indexPath:(NSIndexPath *)indexPath {
    NSMutableSet *set = [self registeredCells];
    NSString *className = [cellClass className];
    if (![set containsObject:className]) {
        [self registerNib:[UINib nibWithNibName:className bundle:nil] forCellWithReuseIdentifier:className];
    }
    return [self dequeueReusableCellWithReuseIdentifier:className forIndexPath:indexPath];
}

- (NSMutableSet *)registeredCells {
    NSMutableSet *registeredCells = objc_getAssociatedObject(self, kCollecitonViewKey);
    if (!registeredCells) {
        registeredCells = [NSMutableSet set];
        objc_setAssociatedObject(self, kCollecitonViewKey, registeredCells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return registeredCells;
}

- (NSArray *)reloadAnimated:(BOOL)animated oldData:(NSArray *)oldData data:(NSArray *)data completion:(dispatch_block_t)compleiton {
    if (!animated || !oldData.count || !self.window) {
        
        [self reloadData];
        if (compleiton) compleiton();
        return nil;
    }
    
    NSMutableArray *toAdd = [NSMutableArray array];
    NSMutableArray *toDelete = [NSMutableArray array];
    NSMutableArray *toReload = [NSMutableArray array];
    
    NSMutableSet *oldDataSet = [NSMutableSet setWithArray:oldData];
    NSMutableSet *dataSet = [NSMutableSet setWithArray:data];
    
    NSMutableOrderedSet *currentSet = [NSMutableOrderedSet orderedSetWithArray:oldData];
    for (NSUInteger index = 0; index < oldData.count; index++) {
        id object = oldData[index];
        if (![dataSet containsObject:object]) {
            [toDelete addObject:[NSIndexPath indexPathForItem:index inSection:0]];
            [currentSet removeObject:object];
        }
    }
    
    for (NSUInteger index = 0; index < data.count; index++) {
        id object = data[index];
        if (![oldDataSet containsObject:object]) {
            [toAdd addObject:[NSIndexPath indexPathForItem:index inSection:0]];
            [currentSet insertObject:object atIndex:index];
        } else {
            [toReload addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }
    }
    
    NSMutableArray *itemsToMove = [NSMutableArray array];
    for (NSUInteger index = 0; index < data.count; index++) {
        id object = data[index];
        NSUInteger oldDataIndex = [currentSet indexOfObject:object];
        if (index != oldDataIndex) {
            [itemsToMove addObject:@{ @"from" : [NSIndexPath indexPathForItem:[oldData indexOfObject:object] inSection:0],
                                      @"to" : [NSIndexPath indexPathForItem:index inSection:0] }];
        }
    }
    
    if (toDelete.count || toAdd.count || itemsToMove.count) {
        
        [self performBatchUpdates:^{
            [self deleteItemsAtIndexPaths:toDelete];
            [self insertItemsAtIndexPaths:toAdd];
            for (NSDictionary *dict in itemsToMove) {
                [self moveItemAtIndexPath:dict[@"from"] toIndexPath:dict[@"to"]];
            }
        } completion:^(BOOL finished) {
            if (compleiton) {
                compleiton();
            }
        }];
    } else {
        if (compleiton) {
            compleiton();
        }
    }
    return toReload;
}

@end