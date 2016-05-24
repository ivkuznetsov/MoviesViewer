//
//  Database.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface Database : NSObject

+ (instancetype)sharedDB;
+ (void)save;
+ (void)performSync:(dispatch_block_t)block; //you must run this methon in background thread only

+ (NSManagedObjectContext *)managedObjectContext;

@end