//
//  ObjectsContainer.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "ObjectsContainer.h"
#import <AMDatabase/AMDatabase.h>

@interface ObjectsContainer()

@property (nonatomic) NSMutableArray *objects;
@property (nonatomic) NSString *key;
@property (nonatomic) Class objectClass;

@end

@implementation ObjectsContainer

- (instancetype)initWithClass:(Class)class uidKey:(NSString *)uidKey {
    if (self = [super init]) {
        _key = uidKey;
        _objectClass = class;
        _objects = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:_key]];
    }
    return self;
}

- (void)add:(NSManagedObject *)object {
    [_objects addObject:[object valueForKey:_key]];
    [self save];
}

- (void)remove:(NSManagedObject *)object {
    [_objects removeObject:[object valueForKey:_key]];
    [self save];
}

- (BOOL)isFavourite:(NSManagedObject *)object {
    return [_objects containsObject:[object valueForKey:_key]];
}

- (NSUInteger)objectsCount {
    return _objects.count;
}

- (NSArray<NSManagedObject *> *)allObjectsIn:(NSManagedObjectContext *)ctx {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *uid in _objects) {
        NSManagedObject *object = [_objectClass findFirstIn:ctx criteria:@"uid == %@", uid];
        if (object) {
            [array addObject:object];
        }
    }
    return array;
}

- (void)save {
    [[NSUserDefaults standardUserDefaults] setObject:_objects forKey:_key];
    [self postNotificaiton:[AMNotification new]];
}

@end
