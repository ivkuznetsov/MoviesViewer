//
//  NSManagedObject+Notifications.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Notifications)

+ (void)addObserver:(NSObject *)observer selector:(SEL)selector;
+ (void)removeObserver:(NSObject *)observer;
+ (void)postUpdateWithObject:(id)object;

+ (void)addObserver:(NSObject *)observer selector:(SEL)selector classes:(NSArray *)classes;
+ (void)removeObserver:(NSObject *)observer classes:(NSArray *)classes;
+ (void)postUpdateForClasses:(NSArray *)classes object:(id)object;

@end