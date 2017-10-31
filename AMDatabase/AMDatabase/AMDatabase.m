//
//  Database.m
//  AMDatabase
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "AMDatabase.h"
#import "NSManagedObjectContext+AMDatabase.h"

@interface AMDatabase ()

@property (nonatomic) NSString *modelName;
@property (nonatomic) NSPersistentStoreCoordinator *storeCoordinator;
@property (nonatomic) NSManagedObjectModel *objectModel;

// main queue context for UI
@property (nonatomic) NSManagedObjectContext *viewContext;

// context for writing to persistent store
@property (nonatomic) NSManagedObjectContext *writerContext;

@property (nonatomic) dispatch_queue_t serialQueue;

@end

@implementation AMDatabase
@synthesize storeDescriptions = _storeDescriptions;

- (instancetype)init {
    if (self = [super init]) {
        _serialQueue = dispatch_queue_create("database.serialqueue", DISPATCH_QUEUE_SERIAL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (void)contextChanged:(NSNotification *)notification {
    if ([notification object] == _writerContext && [notification object] != _viewContext) {
        [_viewContext performBlock:^{
            [_viewContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (NSManagedObjectID *)idForURIRepresentation:(NSURL *)uri {
    return [self.storeCoordinator managedObjectIDForURIRepresentation:uri];
}

- (void)reset {
    [self setupPersistentStore];
}

- (NSManagedObjectContext *)createPrivateContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.database = self;
    context.parentContext = self.writerContext;
    return context;
}

- (NSManagedObjectContext *)writerContext {
    if (!_writerContext) {
        [self setupPersistentStore];
    }
    return _writerContext;
}

- (NSManagedObjectContext *)viewContext {
    if (!_viewContext) {
        [self setupPersistentStore];
    }
    return _viewContext;
}

- (NSPersistentStoreCoordinator *)storeCoordinator {
    if (!_storeCoordinator) {
        [self setupPersistentStore];
    }
    return _storeCoordinator;
}

- (void)perform:(void(^)(NSManagedObjectContext *))block {
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(self.serialQueue, ^{
                NSManagedObjectContext *context = [self createPrivateContext];
                [context performBlockAndWait:^{
                    block(context);
                }];
            });
        });
    } else {
        dispatch_sync(self.serialQueue, ^{
            NSManagedObjectContext *context = [self createPrivateContext];
            [context performBlockAndWait:^{
                block(context);
            }];
        });
    }
}

+ (void)save:(NSManagedObjectContext *)context {
    [context.database save:context];
}

- (void)save:(NSManagedObjectContext *)context {
    NSAssert(context != _viewContext, @"View context cannot be saved");
    
    if ([context hasChanges]) {
        [context performBlockAndWait:^{
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"%@", error.localizedDescription);
                return;
            }
            
            // save writer context
            if (context.parentContext == _writerContext && [context.parentContext hasChanges]) {
                UIBackgroundTaskIdentifier taskIdentifier = 0;
                UIApplication *application = nil;
                if ([UIApplication respondsToSelector:@selector(sharedApplication)]) { //for extensions support
                    application = [UIApplication valueForKey:@"sharedApplication"];
                    taskIdentifier = [application beginBackgroundTaskWithExpirationHandler:nil];
                }
        
                [context.parentContext performBlockAndWait:^{
                    NSError *error = nil;
                    if (![context.parentContext save:&error]) {
                        NSLog(@"%@", error.localizedDescription);
                    }
                    [application endBackgroundTask:taskIdentifier];
                }];
            }
        }];
    }
}

- (NSArray<AMStoreDescription *> *)storeDescriptions {
    if (!_storeDescriptions) {
        _storeDescriptions = @[AMStoreDescription.userDataStore];
    }
    
    //user must not edit store description after initialization, so return full copy
    return [[NSArray alloc] initWithArray:_storeDescriptions copyItems:YES];;
}

- (void)setStoreDescriptions:(NSArray<AMStoreDescription *> *)storeDescriptions {
    //user must not edit store description after initialization, so return full copy
    _storeDescriptions = [[NSArray alloc] initWithArray:storeDescriptions copyItems:YES];
}

- (NSPersistentStore *)persistentStoreAtURL:(NSURL *)url {
    return [self.storeCoordinator persistentStoreForURL:url];
}

- (AMStoreDescription *)storeDescriptionForConfiguration:(NSString *)configuration {
    NSMutableArray *descriptions = [NSMutableArray new];
    
    for (AMStoreDescription *description in self.storeDescriptions) {
        if ([description.configuration isEqualToString:configuration]) {
            [descriptions addObject:description];
        }
    }
    
    NSAssert(descriptions.count, @"You have not provided store description for configuration %@", configuration);
    NSAssert(descriptions.count == 1, @"You have provided more than one store description for configuration %@", configuration);
    
    return [descriptions.firstObject copy];
}

- (NSPersistentStore *)persistentStoreForConfiguration:(NSString *)configuration {
    AMStoreDescription *desc = [self storeDescriptionForConfiguration:configuration];
    return [self persistentStoreAtURL:desc.url];
}

- (void)dispatchSyncOnMainThread:(dispatch_block_t)block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void)setupPersistentStore {
    [self dispatchSyncOnMainThread:^{
        NSMutableArray *bundles = [NSMutableArray arrayWithObject:[NSBundle mainBundle]];
    
        if (_customModelBundle) {
            [bundles addObject:_customModelBundle];
        }
    
        _objectModel = [NSManagedObjectModel mergedModelFromBundles:bundles];
    
        _storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_objectModel];
    
        [self addStoresToPersistentStoreCoordinator:_storeCoordinator];
    
        _writerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _writerContext.persistentStoreCoordinator = _storeCoordinator;
        _writerContext.database = self;
        [_writerContext setMergePolicy:NSOverwriteMergePolicy];
        
        _viewContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _viewContext.parentContext = _writerContext;
        _writerContext.database = self;
        [_viewContext setMergePolicy:NSRollbackMergePolicy];
    }];
}

- (void)addStoresToPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator {
    for (NSString *configurationIdentifier in coordinator.managedObjectModel.configurations) {
        [self addStoreWithConfiguration:configurationIdentifier toCooridnator:coordinator];
    }
}

- (void)addStoreWithConfiguration:(NSString *)configuration toCooridnator:(NSPersistentStoreCoordinator *)coordinator {
    AMStoreDescription *storeDescription = [self storeDescriptionForConfiguration:configuration];
    
    NSMutableDictionary *options = [@{NSMigratePersistentStoresAutomaticallyOption : @YES,
                                      NSInferMappingModelAutomaticallyOption : @YES} mutableCopy];
    
    if (storeDescription.readOnly) {
        options[NSReadOnlyPersistentStoreOption] = @YES;
    }
    
    if (storeDescription.options) {
        [options addEntriesFromDictionary:storeDescription.options];
    }
    
    NSError *error = nil;
    
    [coordinator addPersistentStoreWithType:storeDescription.type
                              configuration:configuration
                                        URL:storeDescription.url
                                    options:options
                                      error:&error];
    
    NSLog(@"Store has been added: %@", storeDescription.url);
    
    if (error) {
        NSLog(@"Error while creating persistent store: %@ for configuration: %@", error, configuration);
        
        if (storeDescription.deleteOnError) {
            [storeDescription removeStoreFiles];
            [self addStoreWithConfiguration:configuration toCooridnator:coordinator];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}

@end
