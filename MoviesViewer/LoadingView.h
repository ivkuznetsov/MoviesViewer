//
//  LoadingView.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

@property (nonatomic) BOOL translucent;

+ (instancetype)presentInView:(UIView *)view animated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

@end