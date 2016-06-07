//
//  UICollectionView+Additions.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (Additions)

- (UICollectionViewCell *)createCellWithCellClass:(Class)cellClass indexPath:(NSIndexPath *)indexPath;
- (NSArray *)reloadAnimated:(BOOL)animated oldData:(NSArray *)oldData data:(NSArray *)data completion:(dispatch_block_t)compleiton;

@end