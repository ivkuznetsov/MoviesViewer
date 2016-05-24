//
//  BaseViewController.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LoadingTypeFull,
    LoadingTypeTranslucent,
    LoadingTypeNone,
} LoadingType;

typedef enum : NSUInteger {
    ErrorTypeFull,
    ErrorTypeAlert,
    ErrorTypeBanner,
    ErrorTypeNone
} ErrorType;

typedef void(^HandleOperation)(NSOperation *operation);

@interface BaseViewController : UIViewController

@property (nonatomic, weak) NSOperation *currentOperation;

- (void)runBlock:(void(^)(CompletionBlock, HandleOperation))block
      completion:(CompletionBlock)completion
         loading:(LoadingType)loadingType
       errorType:(ErrorType)errorType;

- (IBAction)closeAction;

@end