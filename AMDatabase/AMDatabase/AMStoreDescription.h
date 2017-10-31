//
//  AMStoreDescription.h
//  AMDatabase
//
//  Created by Fectum on 26/03/17.
//  Copyright © 2017 Arello-Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const AMCoreDataDefaultConfigurationName;

//Similarly to NSPersistentStoreDescription, an instance of AMStoreDescription encapsulates all information needed to describe a persistent store.
@interface AMStoreDescription : NSObject <NSCopying>

@property (nonatomic, readonly) NSURL *url;

@property (nonatomic) NSString *type;           //NSSQLiteStoreType by default
@property (nonatomic) NSString *configuration;  //AMCoreDataDefaultConfigurationName by default
@property (nonatomic) BOOL readOnly;            //NO by default
@property (nonatomic) BOOL deleteOnError;       //Should framework to delete sqlite file if there is an error occured during store creation and try again. NO by default
@property (nonatomic) NSDictionary *options;

- (instancetype)initWithURL:(NSURL *)url;

@end

@interface AMStoreDescription (CommonStores)

/*
 url:           Library/Caches/<bundle identifier>/<databaseFileName>.sqlite
 type:          NSSQLiteStoreType
 configuration: AMCoreDataDefaultConfigurationName
 readonly:      NO
 deleteOnError: YES. We can just delete old app data (e.g. cache) and create new sqlite file
 */
+ (instancetype)appDataStore;

/*
 url:           Library/Application Support/<bundle identifier>/<databaseFileName>.sqlite
 type:          NSSQLiteStoreType
 configuration: AMCoreDataDefaultConfigurationName
 readonly:      NO
 deleteOnError: NO. We should not delete user data even if store initialization has failed.
 */
+ (instancetype)userDataStore;

/*
 url:           memory://
 type:          NSInMemoryStoreType
 configuration: AMCoreDataDefaultConfigurationName
 readonly:      NO
 deleteOnError: YES
 */
+ (instancetype)transientStore;

@end

@interface AMStoreDescription (FileControl)

//Copy existing store file (for ex. from App Bundle) to store url. Copying will be successful only if the file at target url does not exist.
- (NSError *)copyStoreFileFromURL:(NSURL *)existingStoreURL;

- (void)removeStoreFiles;

@end
