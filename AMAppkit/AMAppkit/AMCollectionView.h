//
//  AMCollectionView.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMCollectionView : UICollectionView

- (UICollectionViewCell *)createCellForClass:(Class)cellClass indexPath:(NSIndexPath *)indexPath;

@end
