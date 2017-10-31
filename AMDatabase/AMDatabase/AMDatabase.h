//
//  Database.h
//  AMDatabase
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+AMDatabase.h"
#import "NSManagedObjectContext+AMDatabase.h"
#import "AMStoreDescription.h"

@interface AMDatabase : NSObject

@property (nonatomic, copy) NSArray<AMStoreDescription *> *storeDescriptions; //@[AMStoreDescription.userDataStore] by default

// if you use .xcdatamodel from framework
@property (nonatomic) NSBundle *customModelBundle;

- (void)reset;

- (NSManagedObjectContext *)viewContext;
- (NSManagedObjectContext *)createPrivateContext;

// perform all edit actions with this method, it will run synchronously if it's dispatched on background queue
- (void)perform:(void(^)(NSManagedObjectContext *ctx))block;
+ (void)save:(NSManagedObjectContext *)context;

- (NSManagedObjectID *)idForURIRepresentation:(NSURL *)uri;

@end
