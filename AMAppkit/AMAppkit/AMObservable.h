//
//  AMObservable.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMNotificationManager.h"

@interface AMObservable : NSObject

+ (NSString *)notificationName;
+ (void)addUpdatesObserver:(id)observer block:(void(^)(AMNotification *))block;

// removing observer is not necessary, it will be removed after object gets deallocated
+ (void)removeUpdatesObserver:(id)observer;

+ (void)postNotificaiton:(AMNotification *)notification;
- (void)postNotificaiton:(AMNotification *)notification;

@end
