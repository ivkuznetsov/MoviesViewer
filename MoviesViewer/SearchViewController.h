//
//  SearchViewController.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "CollectionViewController.h"

@interface SearchViewController : CollectionViewController

@property (nonatomic, readonly) UISearchController *searchController;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

@end