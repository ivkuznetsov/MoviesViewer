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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    [self setupAppearance];
    
    [self createDefaultData:^{
        UITabBarController *tc = [UITabBarController new];
        tc.viewControllers = @[ [[BaseNavigationController alloc] initWithRootViewController:[ExploreViewController new]
                                                                                  tabbarItem:UITabBarSystemItemSearch],
                                [[BaseNavigationController alloc] initWithRootViewController:[[FavouritesViewController alloc] initWithContainer:AppContainer.shared.favorites]
                                                                                  tabbarItem:UITabBarSystemItemFavorites] ];
        _window.rootViewController = tc;
        [_window makeKeyAndVisible];
    }];
    
    return YES;
}

- (void)setupAppearance {
    [[UINavigationBar appearanceWhenContainedIn:[BaseNavigationController class], nil] setTintColor:[UIColor blackColor]];
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
}

- (void)createDefaultData:(dispatch_block_t)completion {
    if (![Movie allObjects:AppContainer.shared.database.viewContext].count) {
        [AppContainer.shared.database perform:^(NSManagedObjectContext *ctx) {
            for (NSString *movieId in [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"PredefinedData" withExtension:@"plist"]]) {
                Movie *movie = [Movie createIn:ctx];
                movie.uid = movieId;
            }
            [AMDatabase save:ctx];
            dispatch_async(dispatch_get_main_queue(), completion);
        }];
    } else {
        completion();
    }
}

@end
