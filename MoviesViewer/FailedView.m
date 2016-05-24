//
//  FailedView.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "FailedView.h"
#import "UIView+LoadFromNib.h"

@interface FailedView()

@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@end

@implementation FailedView

+ (instancetype)presentInView:(UIView*)view withText:(NSString *)text {
    FailedView *failedView = [FailedView loadFromNib];
    failedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    failedView.frame = view.bounds;
    failedView.textLabel.text = text;
    [view addSubview:failedView];
    return failedView;
}

@end
