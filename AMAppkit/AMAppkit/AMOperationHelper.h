//
//  AMOperationHelper.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AMAppearanceSupportObject.h"

typedef void (^AMHandleOperation)(id operation);
typedef void (^AMCompletion)(id object, NSError *requestError);
typedef void (^AMProgress)(CGFloat progress);

typedef enum : NSUInteger {
    AMLoadingTypeFullscreen,
    AMLoadingTypeTranslucent,
    AMLoadingTypeTouchable,
    AMLoadingTypeNone,
} AMLoadingType;

@interface AMOperationHelper : AMAppearanceSupportObject

@property (nonatomic) void(^processTranslucentError)(NSError *error, dispatch_block_t retryBlock); //required for using AMLoadingTypeTranslucent. retry block can be nil //AMAppearance support
@property (nonatomic) BOOL(^shouldSupplyRetry)(id object, NSError *error); //by default retry appears in all operations //AMAppearance support

@property (nonatomic) Class loadingViewClass; //AMLoadingView subclasses //AMAppearance support
@property (nonatomic) Class loadingBarViewClass; //AMLoadingBarView subclasses //AMAppearance support
@property (nonatomic) Class failedViewClass; //AMFailedView subclasses //AMAppearance support
@property (nonatomic) Class failedBarViewClass; //AMAlertBarView subclasses //AMAppearance support

- (instancetype)initWithView:(UIView *)view;

// progress indicator becomes visible on first AMProgress block performing
// 'key' is needed to cancel previous launched operation with the same key, you can pass nil if you don't need such functional
- (void)runBlock:(void(^)(AMCompletion, AMHandleOperation, AMProgress))block
      completion:(AMCompletion)completion
         loading:(AMLoadingType)loadingType
             key:(NSString *)key;
- (void)cancellOperations;

@end
