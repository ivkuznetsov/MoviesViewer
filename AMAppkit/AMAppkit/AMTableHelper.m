//
//  AMTableHelper.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMTableHelper.h"
#import "AMBaseTableViewCell.h"
#import "UITableView+Reloading.h"
#import "UIView+LoadingFromFrameworkNib.h"

@interface AMTableHelper()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableDictionary *estimatedHeights;
@property (nonatomic) AMNoObjectsView *noObjectsView;
@property (nonatomic, weak) id<AMTableHelperDelegate> delegate;
@property (nonatomic) UIBarButtonItem *editButton;
@property (nonatomic) UIBarButtonItem *doneButton;

@end

@implementation AMTableHelper

- (instancetype)initWithTableView:(UITableView *)tableView delegate:(id<AMTableHelperDelegate>)delegate {
    if (self = [self init]) {
        _tableView = tableView;
        _delegate = delegate;
        [self setup];
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view delegate:(id<AMTableHelperDelegate>)delegate {
    return [self initWithView:view style:UITableViewStylePlain delegate:delegate];
}

- (instancetype)initWithCustomAdd:(void(^)(UITableView *tableView))addBlock delegate:(id<AMTableHelperDelegate>)delegate {
    return [self initWithStyle:UITableViewStylePlain customAdd:addBlock delegate:delegate];
}

- (instancetype)initWithView:(UIView *)view style:(UITableViewStyle)style delegate:(id<AMTableHelperDelegate>)delegate {
    if (self = [self init]) {
        [self createTableView:style];
        _delegate = delegate;
        _tableView.frame = view.bounds;
        [view addSubview:_tableView];
        [self setup];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style customAdd:(void(^)(UITableView *tableView))addBlock delegate:(id<AMTableHelperDelegate>)delegate {
    if (self = [self init]) {
        [self createTableView:style];
        _delegate = delegate;
        addBlock(_tableView);
        [self setup];
    }
    return self;
}

- (void)setup {
    _estimatedHeights = [NSMutableDictionary dictionary];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    if (!_noObjectsViewClass) {
        self.noObjectsViewClass = [AMNoObjectsView class];
    }
}

- (void)setNoObjectsViewClass:(Class)noObjectsViewClass {
    _noObjectsViewClass = noObjectsViewClass;
    _noObjectsView = [noObjectsViewClass loadFromFrameworkNib];
}

- (void)createTableView:(UITableViewStyle)style {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 150;
    
    for (UIView *view in _tableView.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)view).delaysContentTouches = NO;
        }
    }
}

- (void)setObjects:(NSArray *)objects {
    [self setObjects:objects animated:NO];
}

- (id<NSCopying>)estimatedHeightKeyForObject:(id)object {
    return [NSValue valueWithNonretainedObject:object];
}

- (void)setObjects:(NSArray *)objects animated:(BOOL)animated {
    NSArray *oldObjects = _objects;
    _objects = [NSArray arrayWithArray:objects];
    
    NSMutableArray *array = [_estimatedHeights.allKeys mutableCopy];
    for (id object in _objects) {
        [array removeObject:[self estimatedHeightKeyForObject:object]];
    }
    for (NSValue *value in array) {
        [_estimatedHeights removeObjectForKey:value];
    }
    
    if (animated) {
        UITableViewRowAnimation animation = UITableViewRowAnimationFade;
        if ([_delegate respondsToSelector:@selector(addCellAnimation)]) {
            animated = [_delegate addCellAnimation];
        }
        
        [_tableView reloadWithOldData:oldObjects newData:_objects block:^{
            for (id cell in _tableView.visibleCells) {
                if ([cell isKindOfClass:[AMBaseTableViewCell class]]) {
                    AMBaseTableViewCell *tableCell = (AMBaseTableViewCell *)cell;
                    
                    id object = tableCell.object;
                    if (object) {
                        if ([_objects containsObject:object]) {
                            [_delegate fillCell:tableCell object:object];
                            tableCell.hiddenSeparator = ([_objects indexOfObject:object] == _objects.count - 1 && _tableView.tableFooterView);
                        }
                    } else {
                        tableCell.hiddenSeparator = ([_objects indexOfObject:tableCell] == _objects.count - 1 && _tableView.tableFooterView);
                    }
                    [self customizeCell:cell object:[object isKindOfClass:[UITableViewCell class]] ? nil : object];
                }
            }
        } addAnimation:animation];
    } else {
        [_tableView reloadData];
    }
    BOOL showEmptyView = !_objects.count;
    if ([_delegate respondsToSelector:@selector(needsToShowNoObjectsView)]) {
        showEmptyView = [_delegate needsToShowNoObjectsView];
    }
    if (showEmptyView) {
        _noObjectsView.frame = CGRectMake(0, 0, _tableView.frame.size.width, _tableView.frame.size.height);
        [_tableView addSubview:_noObjectsView];
    } else {
        [_noObjectsView removeFromSuperview];
    }
    [self reloadEditButtonAnimated:animated];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = _objects[indexPath.row];
    
    UITableViewCell *cell = nil;
    if ([object isKindOfClass:[UITableViewCell class]]) {
        cell = object;
    } else {
        Class cellClass = [self cellClassFor:object];
        
        if (!cellClass) {
            cellClass = [_delegate cellClassFor:object];
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
        if (!cell) {
            cell = [cellClass loadFromFrameworkNib];
        }
        
        if ([_delegate respondsToSelector:@selector(fillCell:object:)]){
            [_delegate fillCell:cell object:object];
        }
    }
    
    if ([cell isKindOfClass:[AMBaseTableViewCell class]]) {
        AMBaseTableViewCell *tableCell = (AMBaseTableViewCell *)cell;
        tableCell.hiddenSeparator = (indexPath.row == _objects.count - 1 && _tableView.tableFooterView);
        if (object != tableCell) {
            tableCell.object = object;
        }
    }
    
    [self customizeCell:cell object:[object isKindOfClass:[UITableViewCell class]] ? nil : object];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = UITableViewAutomaticDimension;
    if ([_delegate respondsToSelector:@selector(cellHeightFor:defaultValue:)]) {
        height = [_delegate cellHeightFor:_objects[indexPath.row] defaultValue:height];
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = _objects[indexPath.row];
    if ([object isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = object;
        return cell.bounds.size.height;
    } else {
        NSNumber *value = _estimatedHeights[[self estimatedHeightKeyForObject:object]];
        if (value) {
            return value.floatValue;
        }
        
        CGFloat resultValue = [self estimatedCellHeightFor:object defaultValue:150];
        
        if ([_delegate respondsToSelector:@selector(estimatedCellHeightFor:defaultValue:)]) {
            resultValue = [_delegate estimatedCellHeightFor:object defaultValue:resultValue];
        }
        return resultValue;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(actionFor:)]) {
        if ([_delegate actionFor:_objects[indexPath.row]]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if ([cell isKindOfClass:[AMBaseTableViewCell class]]) {
        AMBaseTableViewCell *tableCell = (AMBaseTableViewCell *)cell;
        
        id object = tableCell.object;
        if (object) {
            _estimatedHeights[[self estimatedHeightKeyForObject:object]] = @(cell.bounds.size.height);
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(editingStyleFor:)]) {
        return [_delegate editingStyleFor:_objects[indexPath.row]] != AMCellEditingStyleNone;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(editingStyleFor:)]) {
        AMCellEditingStyle style = [_delegate editingStyleFor:_objects[indexPath.row]];
        if (style == AMCellEditingStyleDelete || style == AMCellEditingStyleActions) {
            return UITableViewCellEditingStyleDelete;
        } else if (style == AMCellEditingStyleInsert) {
            return UITableViewCellEditingStyleInsert;
        }
    }
    return UITableViewCellEditingStyleNone;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(editingActionsFor:)] && indexPath.row < _objects.count) {
        return [_delegate editingActionsFor:_objects[indexPath.row]];
    }
    return nil;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_delegate deleteObject:_objects[indexPath.row]];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [_delegate insertFor:_objects[indexPath.row]];
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

- (void)scrollToObject:(id)object animated:(BOOL)animated {
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_objects indexOfObject:object] inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:animated];
}

- (void)setNavigationItem:(UINavigationItem *)navigationItem {
    _navigationItem = navigationItem;
    
    if (!_editButton) {
        _editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction)];
    }
    if (!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editAction)];
    }
    [self reloadEditButtonAnimated:NO];
}

- (void)editAction {
    [_tableView setEditing:!_tableView.editing animated:YES];
    [self reloadEditButtonAnimated:YES];
}

- (void)reloadEditButtonAnimated:(BOOL)animated {
    if (_objects.count) {
        if (_tableView.editing) {
            [_navigationItem setRightBarButtonItem:_doneButton animated:animated];
        } else {
            [_navigationItem setRightBarButtonItem:_editButton animated:animated];
        }
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:animated];
        _tableView.editing = NO;
    }
}

- (Class)cellClassFor:(id)object {
    return nil;
}

- (void)customizeCell:(UITableViewCell *)cell object:(id)object {
    
}

- (CGFloat)estimatedCellHeightFor:(id)object defaultValue:(CGFloat)defaultValue {
    return defaultValue;
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

@end
