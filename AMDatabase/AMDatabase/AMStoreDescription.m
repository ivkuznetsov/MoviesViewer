//
//  AMStoreDescription.m
//  AMDatabase
//
//  Created by Fectum on 26/03/17.
//  Copyright © 2017 Arello-Mobile. All rights reserved.
//

#import "AMStoreDescription.h"
#import "AMDatabase.h"

NSString * const AMCoreDataDefaultConfigurationName = @"PF_DEFAULT_CONFIGURATION_NAME";

@implementation AMStoreDescription

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
        _type = NSSQLiteStoreType;
        _configuration = AMCoreDataDefaultConfigurationName;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    AMStoreDescription *storeDescription = [[AMStoreDescription allocWithZone:zone] initWithURL:_url];
    
    storeDescription.type = _type;
    storeDescription.configuration = _configuration;
    storeDescription.readOnly = _readOnly;
    storeDescription.options = _options;
    storeDescription.deleteOnError = _deleteOnError;
    
    return storeDescription;
}

+ (NSString *)databaseFileName {
    NSMutableString *ultimateName = [NSMutableString string];
    NSString *appName = [[NSProcessInfo processInfo] processName];
    
    [ultimateName appendString:[appName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [ultimateName appendString:@".sqlite"];
    
    return ultimateName;
}

@end

@implementation AMStoreDescription (CommonStores)

+ (instancetype)appDataStore {
    NSURL *url = [NSURL fileURLWithPath:[[self applicationCacheDirectory] stringByAppendingPathComponent:[self databaseFileName]]];
    AMStoreDescription *storeDescription = [[AMStoreDescription alloc] initWithURL:url];
    storeDescription.deleteOnError = YES;
    return storeDescription;
}

+ (instancetype)userDataStore {
    NSURL *url = [NSURL fileURLWithPath:[[self applicationSupportDirectory] stringByAppendingPathComponent:[self databaseFileName]]];
    AMStoreDescription *storeDescription = [[AMStoreDescription alloc] initWithURL:url];
    return storeDescription;
}

+ (instancetype)transientStore {
    AMStoreDescription *storeDescription = [[AMStoreDescription alloc] initWithURL:[NSURL URLWithString:@"memory://"]];
    storeDescription.type = NSInMemoryStoreType;
    return storeDescription;
}

+ (NSString *)applicationSupportDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDirectory = paths.firstObject;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:appSupportDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:appSupportDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *fullDirectory = [appSupportDirectory stringByAppendingPathComponent:bundleIdentifier];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return fullDirectory;
}

+ (NSString *)applicationCacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = paths.firstObject;
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *fullDirectory = [cacheDirectory stringByAppendingPathComponent:bundleIdentifier];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return fullDirectory;
}

@end

@implementation AMStoreDescription (FileControl)

- (void)removeStoreFiles {
    NSString *dataBaseDirectory = [_url.path stringByDeletingLastPathComponent];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *filePathes = [[fileManager contentsOfDirectoryAtPath:dataBaseDirectory error:nil] mutableCopy];
    
    for (NSString *fileName in filePathes) {
        if ([fileName containsString:[self.class databaseFileName]]) {
            [fileManager removeItemAtPath:[dataBaseDirectory stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

- (NSError *)copyStoreFileFromURL:(NSURL *)existingStoreURL {
    NSError *error = nil;
    
    if (_url && existingStoreURL && ![[NSFileManager defaultManager] fileExistsAtPath:_url.path]) {
        [[NSFileManager defaultManager] copyItemAtURL:existingStoreURL toURL:_url error:&error];
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    
    return error;
}

@end
