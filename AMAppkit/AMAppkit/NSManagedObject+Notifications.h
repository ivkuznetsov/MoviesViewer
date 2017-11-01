//
//  NSManagedObject+Notifications.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 30/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AMNotification.h"

@interface NSManagedObject (Notifications)

+ (void)addObserver:(NSObject *)observer block:(void(^)(AMNotification *))block classes:(NSArray *)classes;
+ (void)removeObserver:(NSObject *)observer classes:(NSArray *)classes;
+ (void)postUpdateForClasses:(NSArray *)classes notification:(AMNotification *)notification;

@end
