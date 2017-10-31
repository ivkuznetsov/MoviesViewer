//
//  AMNotificationManager.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMNotificationManager.h"

@interface AMObserver : NSObject

@property (nonatomic, weak) id object;
@property (nonatomic, strong) void(^block)(AMNotification *);

@end

@implementation AMObserver

- (NSString *)uid {
    return [NSString stringWithFormat:@"%@%@", _object, _block];
}

@end

@interface AMNotificationManager()

@property (nonatomic) NSMutableDictionary *dictionary;

@end

@implementation AMNotificationManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static AMNotificationManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _dictionary = [NSMutableDictionary new];
    }
    return self;
}

- (void)addObserver:(NSObject *)observer block:(void(^)(AMNotification *))block names:(NSArray *)names {
    
    void(^blockCopy)(AMNotification *) = [block copy];
    
    for (NSString *name in names) {
        NSMutableArray *array = _dictionary[name];
        if (!array) {
            array = [NSMutableArray array];
            _dictionary[name] = array;
        }
        
        AMObserver *obs = [AMObserver new];
        obs.object = observer;
        obs.block = blockCopy;
        [array addObject:obs];
    }
}

- (void)removeObserver:(NSObject *)observer names:(NSArray *)names {
    for (NSString *name in names) {
        NSMutableArray *array = _dictionary[name];
        
        for (AMObserver *obs in [array copy]) {
            if (!obs.object || obs.object == observer) {
                [array removeObject:obs];
            }
        }
    }
}

- (void)runOnMainThread:(dispatch_block_t)block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (void)postNotificationForNames:(NSArray *)names notification:(AMNotification *)notification {
    [self runOnMainThread:^{
        NSMutableArray *postedUpdates = [NSMutableArray array];
        
        for (NSString *name in names) {
            NSMutableArray *array = _dictionary[name];
            
            for (AMObserver *observer in [[array reverseObjectEnumerator] allObjects]) {
                
                if (!observer.object) {
                    [array removeObject:observer];
                    continue;
                }
                if ([postedUpdates containsObject:[observer uid]]) {
                    continue;
                }
                observer.block(notification);
                [postedUpdates addObject:observer.uid];
            }
        }
    }];
}

@end
