//
//  SearchViewController.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <AMAppkit/AMAppkit.h>

@interface SearchViewController : AMBaseViewController

@property (nonatomic, readonly) UISearchController *searchController;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

@end
