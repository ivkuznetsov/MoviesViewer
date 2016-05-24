//
//  AppDelegate.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "AppDelegate.h"
#import "ExploreViewController.h"
#import "FavouritesViewController.h"
#import "BaseNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (![Movie allObjects].count) {
        for (NSString *movieId in [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"PredefinedData" withExtension:@"plist"]]) {
            Movie *movie = [Movie create];
            movie.uid = movieId;
        }
        [Database save];
    }
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self setupAppearance];
    UITabBarController *tc = [UITabBarController new];
    tc.viewControllers = @[ [[BaseNavigationController alloc] initWithRootViewController:[ExploreViewController new]
                                                                              tabbarItem:UITabBarSystemItemSearch],
                            [[BaseNavigationController alloc] initWithRootViewController:[FavouritesViewController new]
                                                                              tabbarItem:UITabBarSystemItemFavorites] ];
    _window.rootViewController = tc;
    [_window makeKeyAndVisible];
    return YES;
}

- (void)setupAppearance {
    [[UINavigationBar appearanceWhenContainedIn:[BaseNavigationController class], nil] setTintColor:[UIColor blackColor]];
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
}

@end