//
//  AlertView.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "AlertView.h"
#import <objc/runtime.h>

@implementation AlertView

+ (NSString*)appName {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
}

+ (void)alertWithMessage:(NSString *)message {
    [self alertWithTitle:[self appName] message:message];
}

+ (void)alertWithMessage:(NSString *)message controller:(UIViewController*)controller {
	[self alertWithTitle:[self appName] message:message controller:controller];
}

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    [self alertWithTitle:title message:message cancelButtonTitle:@"OK" otherButtonTitles:nil resultBlock:nil];
}

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message controller:(UIViewController*)controller {
	[self alertWithTitle:title message:message cancelButtonTitle:@"OK" otherButtonTitles:nil controller:controller resultBlock:nil];
}

+ (void)alertWithMessage:(NSString *)message
       cancelButtonTitle:(NSString *)cancelButton
       otherButtonTitles:(NSArray*)otherButtonTitles
             resultBlock:(AlertCompletionBlock)resultBlock {
	[self alertWithTitle:[self appName] message:message cancelButtonTitle:cancelButton otherButtonTitles:otherButtonTitles controller:nil resultBlock:resultBlock];
}

+ (void)alertWithMessage:(NSString *)message
       cancelButtonTitle:(NSString *)cancelButton
       otherButtonTitles:(NSArray*)otherButtonTitles
              controller:(UIViewController*)controller
             resultBlock:(AlertCompletionBlock)resultBlock {
	[self alertWithTitle:[self appName] message:message cancelButtonTitle:cancelButton otherButtonTitles:otherButtonTitles controller:controller resultBlock:resultBlock];
}

+ (void)alertWithTitle:(NSString*)title
               message:(NSString*)message
     cancelButtonTitle:(NSString*)cancelButton
     otherButtonTitles:(NSArray*)otherButtonTitles
           resultBlock:(AlertCompletionBlock)resultBlock {
	[self alertWithTitle:title message:message cancelButtonTitle:cancelButton otherButtonTitles:otherButtonTitles controller:nil resultBlock:resultBlock];
}

+ (void)alertWithTitle:(NSString*)title
               message:(NSString*)message
     cancelButtonTitle:(NSString*)cancelButton
     otherButtonTitles:(NSArray*)otherButtonTitles
            controller:(UIViewController*)controller
           resultBlock:(AlertCompletionBlock)resultBlock {
	
    NSInteger cancelButtonIndex = cancelButton ? 0 : -1;
    NSInteger firstOtherButtonIndex = cancelButtonIndex + 1;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    void(^block)(NSInteger) = ^(NSInteger buttonIndex){
        if (resultBlock) {
            resultBlock(cancelButtonIndex, firstOtherButtonIndex, buttonIndex);
        }
    };
    
    if (cancelButton) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButton style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            block(cancelButtonIndex);
        }];
        [alertController addAction:cancelAction];
    }
    
    for (NSString *title in otherButtonTitles) {
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            block(firstOtherButtonIndex + [otherButtonTitles indexOfObject:title]);
        }];
        [alertController addAction:otherAction];
    }
    
    if (!controller && [UIApplication respondsToSelector:@selector(sharedApplication)]) {
        controller = [self findTopViewController];
    }
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (UIViewController*)findTopViewController {
	UIApplication *sharedApplication = [UIApplication valueForKey:@"sharedApplication"];
	UIViewController *controller = sharedApplication.keyWindow.rootViewController;
	
	while (controller.presentedViewController) {
		controller = controller.presentedViewController;
	}
	return controller;
}

+ (void)actionSheetWithTitle:(NSString*)title
           cancelButtonTitle:(NSString*)cancelButton
      destructiveButtonIndex:(NSInteger)destructiveIndex
           otherButtonTitles:(NSArray*)otherButtonTitles
                        view:(UIView*)view
                        rect:(CGRect)rect
                 resultBlock:(ActionSheetCompletionBlock)resultBlock {
	
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSInteger cancelButtonIndex = otherButtonTitles.count;
    NSInteger firstOtherButtonIndex = 0;
    
    for (NSString *title in otherButtonTitles) {
        NSUInteger index = [otherButtonTitles indexOfObject:title];
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:title style:index == destructiveIndex ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (resultBlock) {
                resultBlock(destructiveIndex, cancelButtonIndex, firstOtherButtonIndex, firstOtherButtonIndex + index);
            }
        }];
        [alertController addAction:otherAction];
    }
    
    if (cancelButton) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButton style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (resultBlock) {
                resultBlock(destructiveIndex, cancelButtonIndex, firstOtherButtonIndex, cancelButtonIndex);
            }
        }];
        [alertController addAction:cancelAction];
    }
    
    if (kIsIPad) {
        alertController.popoverPresentationController.sourceRect = rect;
        alertController.popoverPresentationController.sourceView = view;
    }
    
    UIViewController *controller = nil;
    UIResponder *responder = view;
    while (![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    controller = (UIViewController*)responder;
    
    if (!controller && [UIApplication respondsToSelector:@selector(sharedApplication)]) {
        controller = [self findTopViewController];
    }
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

@end