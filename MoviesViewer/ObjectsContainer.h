//
//  ObjectsContainer.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "AMObservable.h"

@interface ObjectsContainer : AMObservable

// NSManagedObject class
- (instancetype)initWithClass:(Class)class uidKey:(NSString *)uidKey;

- (void)add:(NSManagedObject *)object;
- (void)remove:(NSManagedObject *)object;
- (BOOL)isFavourite:(NSManagedObject *)object;

- (NSUInteger)objectsCount;
- (NSArray<NSManagedObject *> *)allObjectsIn:(NSManagedObjectContext *)ctx;

@end
