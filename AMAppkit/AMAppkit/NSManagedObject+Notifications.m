//
//  NSManagedObject+Notifications.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 30/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "NSManagedObject+Notifications.h"
#import "AMNotificationManager.h"

@implementation NSManagedObject (Notifications)

+ (void)addObserver:(NSObject *)observer block:(void(^)(AMNotification *))block classes:(NSArray *)classes {
    [[AMNotificationManager sharedManager] addObserver:observer block:block names:[self classNamesWithClasses:classes]];
}

+ (void)removeObserver:(NSObject *)observer classes:(NSArray *)classes {
    [[AMNotificationManager sharedManager] removeObserver:observer names:[self classNamesWithClasses:classes]];
}

+ (void)postUpdateForClasses:(NSArray *)classes notification:(AMNotification *)notification {
    [[AMNotificationManager sharedManager] postNotificationForNames:[self classNamesWithClasses:classes] notification:notification];
}

+ (NSArray *)classNamesWithClasses:(NSArray *)classes {
    NSMutableArray *names = [NSMutableArray array];
    for (Class classObject in classes) {
        [names addObject:NSStringFromClass(classObject)];
    }
    return names;
}

@end
