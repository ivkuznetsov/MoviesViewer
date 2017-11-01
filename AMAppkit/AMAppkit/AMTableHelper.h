//
//  AMTableHelper.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMNoObjectsView.h"
#import "AMAppearanceSupportObject.h"

typedef enum : NSUInteger {
    AMCellEditingStyleNone,
    AMCellEditingStyleDelete,
    AMCellEditingStyleInsert,
    AMCellEditingStyleActions
} AMCellEditingStyle;

@protocol AMTableHelperDelegate <UITableViewDelegate>

@optional
//these methods are required if objects array contains non UITableViewCell instances
- (Class)cellClassFor:(id)object;
- (void)fillCell:(UITableViewCell *)cell object:(id)object;

//BOOL returns is we need to deselect cell
- (BOOL)actionFor:(id)object;

- (CGFloat)cellHeightFor:(id)object defaultValue:(CGFloat)defaultValue;
- (CGFloat)estimatedCellHeightFor:(id)object defaultValue:(CGFloat)defaultValue;
- (AMCellEditingStyle)editingStyleFor:(id)object;
- (NSArray<UITableViewRowAction *> *)editingActionsFor:(id)object;
- (void)deleteObject:(id)object;
- (void)insertFor:(id)object;
- (UITableViewRowAnimation)addCellAnimation;

//by default it becomes visible when objects array is empty
- (BOOL)needsToShowNoObjectsView;

@end

@interface AMTableHelper : AMAppearanceSupportObject

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic) NSArray *objects;

@property (nonatomic, weak) UINavigationItem *navigationItem; // for edit/done button

//empty state
@property (nonatomic) Class noObjectsViewClass; // AMNoObjectsView subclasses //AMAppearance Support
@property (nonatomic, readonly) AMNoObjectsView *noObjectsView;

- (instancetype)initWithTableView:(UITableView *)tableView delegate:(id<AMTableHelperDelegate>)delegate;

//these methods create UITableView, by default tableView fills view, if you need something else use addBlock
- (instancetype)initWithView:(UIView *)view delegate:(id<AMTableHelperDelegate>)delegate;
- (instancetype)initWithCustomAdd:(void(^)(UITableView *tableView))addBlock delegate:(id<AMTableHelperDelegate>)delegate;

- (instancetype)initWithView:(UIView *)view style:(UITableViewStyle)style delegate:(id<AMTableHelperDelegate>)delegate;
- (instancetype)initWithStyle:(UITableViewStyle)style customAdd:(void(^)(UITableView *tableView))addBlock delegate:(id<AMTableHelperDelegate>)delegate;

- (void)setObjects:(NSArray *)objects animated:(BOOL)animated;
- (void)scrollToObject:(id)object animated:(BOOL)animated;

// if you need default cells like separators, or customize cells visually you should use the methods below
// override to define default cells wich may appear in whole app
- (Class)cellClassFor:(id)object;

// this method is called for all the cells your helper or delegate defining. It is not designed to fill the data. Use autolayout for such cells.
- (void)customizeCell:(UITableViewCell *)cell object:(id)object;

- (CGFloat)estimatedCellHeightFor:(id)object defaultValue:(CGFloat)defaultValue;

@end
