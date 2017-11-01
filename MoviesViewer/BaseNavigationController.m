//
//  BaseNavigationController.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "BaseNavigationController.h"

@implementation BaseNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController tabbarItem:(UITabBarSystemItem)item {
    if (self = [super initWithRootViewController:rootViewController]) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:item tag:0];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end