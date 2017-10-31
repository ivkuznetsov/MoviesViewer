//
//  AMObservable.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMObservable.h"

@implementation AMObservable

+ (NSString *)notificationName {
    return NSStringFromClass(self);
}

+ (void)addUpdatesObserver:(id)observer block:(void(^)(AMNotification *))block {
    [[AMNotificationManager sharedManager] addObserver:observer block:block names:@[[self notificationName]]];
}

+ (void)removeUpdatesObserver:(id)observer {
    [[AMNotificationManager sharedManager] removeObserver:observer names:@[[self notificationName]]];
}

+ (void)postNotificaiton:(AMNotification *)notification {
    [[AMNotificationManager sharedManager] postNotificationForNames:@[[self notificationName]] notification:notification];
}

- (void)postNotificaiton:(AMNotification *)notification {
    notification.object = self;
    [self.class postNotificaiton:notification];
}

@end
