//
//  AMCollectionHelper.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMCollectionHelper.h"
#import "UIView+LoadingFromFrameworkNib.h"
#import "AMContainerCell.h"
#import "UICollectionView+Reloading.h"

@interface AMCollectionHelper()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) AMCollectionView *collectionView;
@property (nonatomic) AMNoObjectsView *noObjectsView;
@property (nonatomic, weak) id<AMCollectionHelperDelegate> delegate;
@property (nonatomic) BOOL updatingDatasource;
@property (nonatomic, strong) NSArray *lazyObjects;

@end

@implementation AMCollectionHelper

- (instancetype)initWithCollectionView:(AMCollectionView *)collectionView delegate:(id<AMCollectionHelperDelegate>)delegate {
    if (self = [super init]) {
        _collectionView = collectionView;
        _delegate = delegate;
        [self setup];
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view delegate:(id<AMCollectionHelperDelegate>)delegate {
    if (self = [super init]) {
        [self createCollectionView];
        _collectionView.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
        [view addSubview:_collectionView];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:@{ @"collectionView" : _collectionView }]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:@{ @"collectionView" : _collectionView }]];
        
        _delegate = delegate;
        [self setup];
    }
    return self;
}

- (instancetype)initWithCustomAdd:(void(^)(UICollectionView *collectionView))addBlock delegate:(id<AMCollectionHelperDelegate>)delegate {
    if (self = [super init]) {
        [self createCollectionView];
        _delegate = delegate;
        addBlock(_collectionView);
        [self setup];
    }
    return self;
}

- (void)createCollectionView {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _collectionView = [[AMCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    //_collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.alwaysBounceVertical = YES;
}

- (void)setup {
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    if (!_noObjectsViewClass) {
        self.noObjectsViewClass = [AMNoObjectsView class];
    }
    [_collectionView registerClass:[AMContainerCell class] forCellWithReuseIdentifier:NSStringFromClass([AMContainerCell class])];
}

- (void)setNoObjectsViewClass:(Class)noObjectsViewClass {
    _noObjectsViewClass = noObjectsViewClass;
    _noObjectsView = [noObjectsViewClass loadFromFrameworkNib];
}

- (void)setObjects:(NSArray *)objects animated:(BOOL)animated {
    if (_updatingDatasource) {
        _lazyObjects = objects;
    } else {
        _updatingDatasource = YES;
        __weak typeof(self) weakSelf = self;
        [self setObjects:objects animated:animated completion:^{
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
    
    NSArray *toReload = [_collectionView reloadAnimated:animated oldData:oldObjects data:_objects completion:completion];
    
    if (animated) {
        for (NSIndexPath *indexPath in toReload) {
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
            if (cell && ![cell isKindOfClass:[AMContainerCell class]]) {
                [_delegate fillCell:cell object:_objects[indexPath.item]];
            }
        }
    }
    BOOL showEmptyView = !_objects.count;
    if ([_delegate respondsToSelector:@selector(needsToShowNoObjectsView)]) {
        showEmptyView = [_delegate needsToShowNoObjectsView];
    }
    if (showEmptyView) {
        _noObjectsView.frame = CGRectMake(0, 0, _collectionView.frame.size.width, _collectionView.frame.size.height);
        [_collectionView addSubview:_noObjectsView];
    } else {
        [_noObjectsView removeFromSuperview];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL result = [super respondsToSelector:aSelector];
    if (!result) {
        return [_delegate respondsToSelector:aSelector];
    }
    return result;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (![super respondsToSelector:aSelector]) {
        return _delegate;
    }
    return self;
}

- (UICollectionViewFlowLayout *)layout {
    return (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = _objects[indexPath.item];
    if ([object isKindOfClass:[UIView class]]) {
        UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([AMContainerCell class]) forIndexPath:indexPath];
        
        UIView *view = object;
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        view.frame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
        [cell.contentView addSubview:view];
        
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view" : view}]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view" : view}]];
        
        return cell;
    } else {
        UICollectionViewCell *cell = [_collectionView createCellForClass:[_delegate cellClassFor:object] indexPath:indexPath];
        [_delegate fillCell:cell object:object];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(actionFor:)]) {
        if ([_delegate actionFor:_objects[indexPath.row]]) {
            [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = _objects[indexPath.item];
    if ([object isKindOfClass:[UIView class]]) {
        UIEdgeInsets insets = self.layout.sectionInset;
        CGFloat defaultWidth = collectionView.frame.size.width - insets.left - insets.right;
        
        if ([_delegate respondsToSelector:@selector(cellSizeForView:defaultSize:)]) {
            CGSize size = [object systemLayoutSizeFittingSize:CGSizeMake(defaultWidth, UILayoutFittingCompressedSize.height)];
            size.width = defaultWidth;
            return [_delegate cellSizeForView:object defaultSize:size];
        }
        
        CGRect frame = [object frame];
        frame.size.width = defaultWidth;
        [object setFrame:frame];
        [object layoutIfNeeded];
        
        return CGSizeMake(frame.size.width, [object systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
    } else {
        return [_delegate cellSizeFor:object];
    }
}

@end
