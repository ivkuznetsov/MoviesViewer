//
//  AlertView.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AlertCompletionBlock) (NSInteger cancelIndex, NSInteger firstOtherIndex, NSInteger buttonIndex);
typedef void (^ActionSheetCompletionBlock) (NSInteger destructiveIndex, NSInteger cancelIndex, NSInteger firstOtherIndex, NSInteger buttonIndex);

@interface AlertView : NSObject

+ (void)alertWithMessage:(NSString *)message NS_EXTENSION_UNAVAILABLE_IOS("use with controller:");
+ (void)alertWithMessage:(NSString *)message controller: (UIViewController*) controller;

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message NS_EXTENSION_UNAVAILABLE_IOS("use with controller:");
+ (void)alertWithTitle:(NSString *)title message:(NSString *)message controller:(UIViewController*)controller;

+ (void)alertWithMessage:(NSString *)message
       cancelButtonTitle:(NSString *)cancelButton
       otherButtonTitles:(NSArray*)otherButtonTitles
             resultBlock:(AlertCompletionBlock)resultBlock NS_EXTENSION_UNAVAILABLE_IOS("use with controller:");

+ (void)alertWithMessage:(NSString *)message
       cancelButtonTitle:(NSString *)cancelButton
       otherButtonTitles:(NSArray*)otherButtonTitles
              controller:(UIViewController*)controller
             resultBlock:(AlertCompletionBlock)resultBlock;

+ (void)alertWithTitle:(NSString*)title
               message:(NSString*)message
	 cancelButtonTitle:(NSString*)cancelButton
	 otherButtonTitles:(NSArray*)otherButtonTitles
           resultBlock:(AlertCompletionBlock)resultBlock NS_EXTENSION_UNAVAILABLE_IOS("use with controller:");

+ (void)alertWithTitle:(NSString*)title
               message:(NSString*)message
     cancelButtonTitle:(NSString*)cancelButton
	 otherButtonTitles:(NSArray*)otherButtonTitles
			controller:(UIViewController*)controller
		   resultBlock:(AlertCompletionBlock)resultBlock;

+ (void)actionSheetWithTitle:(NSString*)title
           cancelButtonTitle:(NSString*)cancelButton
      destructiveButtonIndex:(NSInteger)destructiveIndex
           otherButtonTitles:(NSArray*)otherButtonTitles
                        view:(UIView*)view
                        rect:(CGRect)rect
                 resultBlock:(ActionSheetCompletionBlock)resultBlock;

@end