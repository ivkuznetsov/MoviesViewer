//
//  NSManagedObject+Notifications.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "NSManagedObject+Notifications.h"

@implementation NSManagedObject (Notifications)

+ (void)addObserver:(NSObject *)observer selector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:[self.class notificationKey] object:nil];
}

+ (void)removeObserver:(NSObject *)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:[self.class notificationKey] object:nil];
}

+ (void)postUpdateWithObject:(id)object {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationKey] object:object];
    });
}

+ (NSString *)notificationKey {
    return [NSString stringWithFormat:@"%@UpdateNotification", [self className]];
}

+ (void)addObserver:(NSObject *)observer selector:(SEL)selector classes:(NSArray *)classes {
    for (Class objectClass in classes) {
        [objectClass addObserver:observer selector:selector];
    }
}

+ (void)removeObserver:(NSObject *)observer classes:(NSArray *)classes {
    for (Class objectClass in classes) {
        [objectClass removeObserver:observer];
    }
}

+ (void)postUpdateForClasses:(NSArray *)classes object:(id)object {
    for (Class objectClass in classes) {
        [objectClass postUpdateWithObject:object];
    }
}

@end
