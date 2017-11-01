//
//  AMCollectionHelper.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AMCollectionView.h"
#import "AMNoObjectsView.h"
#import "AMAppearanceSupportObject.h"

@protocol AMCollectionHelperDelegate <UICollectionViewDelegate>

@optional
//these methods are required if objects array contains non UIView instances
- (Class)cellClassFor:(id)object;
- (void)fillCell:(UICollectionViewCell *)cell object:(id)object;
- (CGSize)cellSizeFor:(id)object;

//BOOL returns is we need to deselect cell
- (BOOL)actionFor:(id)object;

- (CGSize)cellSizeForView:(UIView *)view defaultSize:(CGSize)size;

//by default it becomes visible when objects array is empty
- (BOOL)needsToShowNoObjectsView;

@end

@interface AMCollectionHelper : AMAppearanceSupportObject

@property (nonatomic, readonly) AMCollectionView *collectionView;
@property (nonatomic, readonly) UICollectionViewFlowLayout *layout;
@property (nonatomic) NSArray *objects;

//empty state
@property (nonatomic) Class noObjectsViewClass; // AMNoObjectsView subclasses //AMAppearance support
@property (nonatomic, readonly) AMNoObjectsView *noObjectsView;

- (instancetype)initWithCollectionView:(AMCollectionView *)collectionView delegate:(id<AMCollectionHelperDelegate>)delegate;

// these methods create UITableView, by default tableView fills view, if you need something else use addBlock
- (instancetype)initWithView:(UIView *)view delegate:(id<AMCollectionHelperDelegate>)delegate;
- (instancetype)initWithCustomAdd:(void(^)(UICollectionView *collectionView))addBlock delegate:(id<AMCollectionHelperDelegate>)delegate;

- (void)setObjects:(NSArray *)objects animated:(BOOL)animated;

@end
