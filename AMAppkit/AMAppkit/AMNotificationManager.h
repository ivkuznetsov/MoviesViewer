//
//  AMNotificationManager.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMNotification.h"

@interface AMNotificationManager : NSObject

+ (instancetype)sharedManager;
- (void)addObserver:(NSObject *)observer block:(void(^)(AMNotification *))block names:(NSArray *)names;

// removing observer is not necessary, it will be removed after object gets deallocated
- (void)removeObserver:(NSObject *)observer names:(NSArray *)names;
- (void)postNotificationForNames:(NSArray *)names notification:(AMNotification *)notification;

@end
