//
//  AppContainer.h
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 10/29/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMDatabase/AMDatabase.h>
#import "ObjectsContainer.h"
#import "ServiceProvider.h"

@interface AppContainer : NSObject

@property (nonatomic) ObjectsContainer *favorites;

@property (nonatomic) ServiceProvider *service;

@property (nonatomic) AMDatabase *database;

+ (instancetype)shared;

@end
