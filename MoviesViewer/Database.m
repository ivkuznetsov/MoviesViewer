//
//  Database.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "Database.h"

@interface Database ()

@property (nonatomic) NSString *modelName;
@property (nonatomic) NSString *databaseFileName;
@property (nonatomic) NSPersistentStore *persistentStore;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) NSManagedObjectModel *managedObjectModel;

@property (nonatomic) NSManagedObjectContext *writerContext;
@property (nonatomic) NSManagedObjectContext *mainContext;
@property (nonatomic) NSMutableDictionary *backgroundContexts;
@property (nonatomic) dispatch_queue_t serialQueue;

@end

@implementation Database

- (instancetype)init {
    if (self = [super init]) {
        _backgroundContexts = [NSMutableDictionary dictionary];
        _serialQueue = dispatch_queue_create("database.serialqueue", DISPATCH_QUEUE_SERIAL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadWillExit:) name:NSThreadWillExitNotification object:nil];
    }
    return self;
}

+ (instancetype)sharedDB {
    static Database *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [Database new];
    });
    return instance;
}

+ (void) save {
    [[self sharedDB] saveContext:[[self sharedDB] managedObjectContext]];
}

+ (void)performSync:(dispatch_block_t)block {
    if ([NSThread isMainThread]) {
        [NSException raise:NSGenericException format:@"[Database performSync:] could not be executed on main thread"];
    }
    dispatch_sync([Database sharedDB].serialQueue, block);
    [[Database sharedDB].backgroundContexts removeObjectForKey:[NSThread currentThread].name];
}

+ (void) saveWithCompletion: (dispatch_block_t) completion {
    UIBackgroundTaskIdentifier taskIdentifier = 0;
    UIApplication *application = nil;
    if ([UIApplication respondsToSelector:@selector(sharedApplication)]) { //for extensions support
        application = [UIApplication valueForKey:@"sharedApplication"];
        taskIdentifier = [application beginBackgroundTaskWithExpirationHandler:nil];
    }
    
    [self.sharedDB saveContext:[self.sharedDB managedObjectContext] completion:^{
        [application endBackgroundTask:taskIdentifier];
        if (completion) {
            completion();
        }
    }];
}

- (void)saveContext:(NSManagedObjectContext*)context {
    if ([context hasChanges]) {
        [context performBlockAndWait:^{
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"%@", error.localizedDescription);
            }
            if (context.parentContext) {
                if (context.parentContext == _writerContext) {
                    [self saveContext:_writerContext completion:nil];
                } else {
                    [self saveContext:context.parentContext];
                }
            }
        }];
    }
}

- (void)saveContext:(NSManagedObjectContext*)context completion:(dispatch_block_t)completion {
    if ([context hasChanges]) {
        [context performBlock:^{
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"%@", error.localizedDescription);
            }
            if (context.parentContext) {
                if (context.parentContext == _writerContext) {
                    [self saveContext:_writerContext completion:nil];
                    if (completion) {
                        completion();
                    }
                } else {
                    [self saveContext:context.parentContext completion:completion];
                }
            } else {
                if (completion) {
                    completion();
                }
            }
        }];
    }
}

- (void)threadWillExit:(NSNotification*)notification {
    if ([notification.name isEqualToString:NSThreadWillExitNotification]){
        NSThread *thread = notification.object;
        @synchronized (_backgroundContexts) {
            [_backgroundContexts removeObjectForKey:thread.name];
        }
    }
}

- (NSString *)applicationDocumentsDirectory {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

- (void)dispatchSyncOnMainThread:(dispatch_block_t)block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

+ (NSManagedObjectContext *)managedObjectContext {
    return [[self sharedDB] managedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_mainContext) {
        [self dispatchSyncOnMainThread:^{
            if (!_mainContext) {
                _writerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                _writerContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
                [_writerContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                
                _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
                [_mainContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                _mainContext.parentContext = _writerContext;
            }
        }];
    }
    
    if ([NSThread isMainThread]) {
        return _mainContext;
    }
    
    NSString *name = [NSThread currentThread].name;
    if (!name.length) {
        [NSThread currentThread].name = [NSUUID UUID].UUIDString;
        name = [NSThread currentThread].name;
    }
    
    @synchronized (_backgroundContexts) {
        NSManagedObjectContext *context = _backgroundContexts[name];
        if (!context) {
            context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            context.parentContext = _mainContext;
            
            _backgroundContexts[name] = context;
        }
        return context;
    }
}

- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[self databaseFileName]];
    NSURL *storeUrl = [NSURL fileURLWithPath: path];
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES };
    
    NSLog(@"Database store path: %@", storeUrl.path);
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    _persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error];
    
    if (!_persistentStore) {
        NSLog(@"Error while creating persistent store: %@", error);
    }
    return _persistentStoreCoordinator;
}

- (NSString *)databaseFileName {
    NSString *appName = [[[NSProcessInfo processInfo] processName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [appName stringByAppendingPathExtension:@"sqlite"];
}

- (NSString *)databaseFilePath {
    return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[self databaseFileName]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSThreadWillExitNotification object:nil];
}

@end
