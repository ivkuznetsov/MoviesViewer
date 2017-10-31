//
//  UICollectionView+Reloading.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (Reloading)

- (NSArray *)reloadAnimated:(BOOL)animated oldData:(NSArray *)oldData data:(NSArray *)data completion:(dispatch_block_t)completion;

@end
