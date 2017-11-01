//
//  AMFooterLoadingView.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 05/02/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    AMFooterStateUndefined,
    AMFooterStateStop,
    AMFooterStateLoading,
    AMFooterStateFailed,
} AMFooterState;

@interface AMFooterLoadingView : UIView

@property (nonatomic) AMFooterState state;
@property (nonatomic) dispatch_block_t retryAction;

@end
