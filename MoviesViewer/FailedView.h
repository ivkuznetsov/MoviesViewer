//
//  FailedView.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FailedView : UIView

+ (instancetype)presentInView:(UIView*)view withText:(NSString *)text;

@end