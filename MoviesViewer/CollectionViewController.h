//
//  CollectionViewController.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "BaseViewController.h"

@interface CollectionViewController : BaseViewController<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *noDataView;
@property (nonatomic) NSArray *objects;

- (void)setObjects:(NSArray *)objects animated:(BOOL)animated;

//override
- (Class)cellClassForObjects:(id)object;
- (void)fillCell:(id)cell withObject:(id)object;
- (void)actionForObject:(id)object;
- (CGSize)cellSizeForObject:(id)object;
- (CGSize)customSizeForView:(UIView *)view;

@end