//
//  BaseNavigationController.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseNavigationController : UINavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController tabbarItem:(UITabBarSystemItem)item;

@end