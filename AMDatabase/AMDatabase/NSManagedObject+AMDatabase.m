//
//  NSManagedObject+AMDatabase.h
//  AMDatabase
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "NSManagedObject+AMDatabase.h"
#import "NSManagedObjectContext+AMDatabase.h"
#import "AMDatabase.h"

@interface AMDatabase()

- (NSPersistentStore *)persistentStoreForConfiguration:(NSString *)configuration;

@end

@implementation NSManagedObject (Database)

+ (instancetype)createIn:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (instancetype)createIn:(NSManagedObjectContext *)context configuration:(NSString *)configuration {
    NSManagedObject *object = [self createIn:context];
    NSPersistentStore *store = [context.database persistentStoreForConfiguration:configuration];
    [context assignObject:object toPersistentStore:store];
    return object;
}

- (void)delete {
    [self.managedObjectContext deleteObject:self];
}

- (BOOL)isObjectDeleted {
    return !self.managedObjectContext || self.isDeleted;
}

+ (NSEntityDescription *)entityDescription:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (NSArray *)execute:(NSFetchRequest *)request context:(NSManagedObjectContext *)context error:(NSError **)error {
    NSEntityDescription *entity = [self entityDescription:context];
    [request setEntity:entity];
    return [context executeFetchRequest:request error:error];
}

+ (NSArray *)allObjects:(NSManagedObjectContext *)context {
    NSFetchRequest *allObjectsRequest = [NSFetchRequest new];
    NSError *error = nil;
    NSArray *result = [self execute:allObjectsRequest context:context error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return result;
}

+ (NSArray *)allObjectsSorted:(NSManagedObjectContext *)context {
    return [self allObjectsSortedBy:@"permanentObjectID.description" context:context];
}

+ (NSArray *)allObjectsSortedBy:(NSString *)key context:(NSManagedObjectContext *)context {
    return [self allObjectsSortedBy:key ascending:YES context:context];
}

+ (NSArray *)allObjectsSortedBy:(NSString *)key ascending:(BOOL)ascending context:(NSManagedObjectContext *)context {
    NSFetchRequest *allObjectsRequest = [NSFetchRequest new];
    allObjectsRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:key ascending:ascending]];
    NSError *error = nil;
    NSArray *result = [self execute:allObjectsRequest context:context error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return result;
}

+ (NSArray *)findIn:(NSManagedObjectContext *)context criteria:(NSString *)criteriaString, ... {
    va_list argumentList;
    va_start(argumentList, criteriaString);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:criteriaString arguments:argumentList];
    va_end(argumentList);
    
    return [self findIn:context predicate:predicate];
}

+ (NSArray *)findIn:(NSManagedObjectContext *)context predicate:(NSPredicate *)predicate {
    NSFetchRequest *request = [NSFetchRequest new];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [[self class] execute:request context:context error:&error];
    
    if (error) {
        [[self class] logError: error];
    }
    return result;
}

+ (instancetype)findFirstIn:(NSManagedObjectContext *)context criteria:(NSString *)criteriaString, ... {
    va_list argumentList;
    va_start(argumentList, criteriaString);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:criteriaString arguments:argumentList];
    va_end(argumentList);
    
    return [self findFirstIn:context predicate:predicate];
}

+ (instancetype)findFirstIn:(NSManagedObjectContext *)context predicate:(NSPredicate *)predicate {
    NSFetchRequest *request = [NSFetchRequest new];
    request.fetchLimit = 1;
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [[self class] execute:request context:context error:&error];
    if (error) {
        [[self class] logError: error];
    }
    return result.firstObject;
}

- (NSManagedObjectID *)permanentObjectID {
    NSManagedObjectID *objectId = self.objectID;
    
    if (objectId.isTemporaryID) {
        [self.managedObjectContext obtainPermanentIDsForObjects:@[self] error:nil];
        objectId = self.objectID;
    }
    return objectId;
}

+ (NSArray *)objectsWithIds:(NSObject<NSFastEnumeration> *)objectIds context:(NSManagedObjectContext *)context {
    NSMutableArray *results = [NSMutableArray array];
    for (NSManagedObjectID *objectId in objectIds) {
        NSManagedObject *object = [self findById:objectId context:context];
        if (object) {
            [results addObject:object];
        }
    }
    return results;
}

+ (NSArray *)idsWithObjects:(NSObject<NSFastEnumeration> *)objects {
    NSMutableArray *results = [NSMutableArray array];
    for (NSManagedObject *object in objects) {
        [results addObject:[object permanentObjectID]];
    }
    return results;
}

+ (NSArray *)uriWithIds:(NSObject<NSFastEnumeration> *)ids {
    NSMutableArray *results = [NSMutableArray array];
    for (NSManagedObjectID *objectId in ids) {
        [results addObject:objectId.URIRepresentation];
    }
    return results;
}

+ (instancetype)findById:(NSManagedObjectID *)objectId context:(NSManagedObjectContext *)context {
    if (!objectId) {
        return nil;
    }
    
    NSError *error = nil;
    NSManagedObject *object = [context existingObjectWithID:objectId error:&error];
    if (error) {
        [[self class] logError: error];
    }
    return object;
}

+ (void)logError:(NSError *)error {
    NSLog(@"Error: %@", error);
    NSArray* detailedErrors = [error userInfo][NSDetailedErrorsKey];
    if (detailedErrors.count) {
        for (NSError* detailedError in detailedErrors) {
            NSLog(@"  DetailedError: %@", [detailedError userInfo]);
        }
    } else {
        NSLog(@"  %@", [error userInfo]);
    }
}

@end
