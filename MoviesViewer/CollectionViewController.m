//
//  CollectionViewController.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "CollectionViewController.h"
#import "ContainerCell.h"
#import "UICollectionView+Additions.h"

@interface CollectionViewController ()

@property (nonatomic) BOOL updatingDatasource;
@property (nonatomic, strong) NSArray *lazyObjects;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setObjects:(NSArray *)objects {
    [self setObjects:objects animated:NO];
}

- (void)setObjects:(NSArray *)objects animated:(BOOL)animated {
    if (!_collectionView) {
        return;
    }
    
    if (_updatingDatasource) {
        _lazyObjects = objects;
    } else {
        _updatingDatasource = YES;
        __weak typeof(self) weakSelf = self;
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self setObjects:objects animated:animated completion:^{
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            if (weakSelf.lazyObjects) {
                [weakSelf setObjects:weakSelf.lazyObjects animated:NO completion:nil];
                weakSelf.lazyObjects = nil;
            }
            weakSelf.updatingDatasource = NO;
        }];
    }
}

- (void)setObjects:(NSArray *)objects animated:(BOOL)animated completion:(dispatch_block_t)completion {
    NSArray *oldObjects = _objects;
    _objects = objects;
    _noDataView.hidden = _objects.count;
    
    NSArray *toReload = [_collectionView reloadAnimated:animated oldData:oldObjects data:_objects completion:completion];
    
    if (animated) {
        for (NSIndexPath *indexPath in toReload) {
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
            if (cell && ![cell isKindOfClass:[ContainerCell class]]) {
                [self fillCell:cell withObject:_objects[indexPath.item]];
            }
        }
    }
}

- (Class)cellClassForObjects:(id)object {
    return nil;
}

- (void)fillCell:(id)cell withObject:(id)object {
    
}

- (void)actionForObject:(id)object {
    
}

- (CGSize)cellSizeForObject:(id)object {
    return CGSizeZero;
}

- (CGSize)customSizeForView:(UIView *)view {
    view.width = _collectionView.width;
    [view layoutIfNeeded];
    return CGSizeMake(_collectionView.width, [view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = _objects[indexPath.item];
    if ([object isKindOfClass:[UIView class]]) {
        ContainerCell *cell = (ContainerCell *)[_collectionView createCellWithCellClass:[ContainerCell class] indexPath:indexPath];
        [cell attachView:object];
        return cell;
    } else {
        UICollectionViewCell *cell = [_collectionView createCellWithCellClass:[self cellClassForObjects:object] indexPath:indexPath];
        [self fillCell:cell withObject:object];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self actionForObject:_objects[indexPath.item]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = _objects[indexPath.item];
    if ([object isKindOfClass:[UIView class]]) {
        return [self customSizeForView:object];
    } else {
        return [self cellSizeForObject:object];
    }
}

@end