/*
 * Arello Mobile
 * Mobile Framework
 * Except where otherwise noted, this work is licensed under a Creative Commons Attribution 3.0 Unported License
 * http://creativecommons.org/licenses/by/3.0
 */

#import "AMAlertView.h"
#import <objc/runtime.h>

#define kAMAlertViewBlock @"kAMAlertViewBlock"
#define kAMAlertViewAction @"kAMAlertViewAction"

@interface AMAlertView()<UIAlertViewDelegate, UIActionSheetDelegate>

@end

@implementation AMAlertView

+ (AMAlertView *)shared {
    static dispatch_once_t once;
    static AMAlertView *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

+ (NSString*)appName {
    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    if (!appName)
        appName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
    return appName;
}

+ (id)alertWithMessage:(NSString *)message {
    return [self alertWithTitle:[self appName] message:message];
}

+ (id)alertWithMessage:(NSString *)message controller:(UIViewController*)controller {
	return [self alertWithTitle:[self appName] message:message controller:controller];
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message {
    return [self alertWithTitle:title message:message cancelButtonTitle:@"OK" otherButtonTitles:nil resultBlock:nil];
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message controller:(UIViewController *)controller {
	return [self alertWithTitle:title message:message cancelButtonTitle:@"OK" otherButtonTitles:nil controller:controller resultBlock:nil];
}

+ (id)alertWithMessage:(NSString *)message
     cancelButtonTitle:(NSString *)cancelButton
     otherButtonTitles:(NSArray*)otherButtonTitles
           resultBlock:(AMAlertCompletionBlock)resultBlock {
    return [self alertWithTitle:[self appName] message:message initialText:nil cancelButtonTitle:cancelButton textField:NO disableButton:NO secured:NO otherButtonTitles:otherButtonTitles controller:nil resultBlock:resultBlock];
}

+ (id)alertWithMessage:(NSString *)message
     cancelButtonTitle:(NSString *)cancelButton
     otherButtonTitles:(NSArray *)otherButtonTitles
            controller:(UIViewController *)controller
           resultBlock:(AMAlertCompletionBlock)resultBlock {
    return [self alertWithTitle:[self appName] message:message initialText:nil cancelButtonTitle:cancelButton textField:NO disableButton:NO secured:NO otherButtonTitles:otherButtonTitles controller:controller resultBlock:resultBlock];
}

+ (id)alertWithTitle:(NSString *)title
             message:(NSString *)message
   cancelButtonTitle:(NSString *)cancelButton
   otherButtonTitles:(NSArray *)otherButtonTitles
         resultBlock:(AMAlertCompletionBlock)resultBlock {
    return [self alertWithTitle:title message:message initialText:nil cancelButtonTitle:cancelButton textField:NO disableButton:NO secured:NO otherButtonTitles:otherButtonTitles controller:nil resultBlock:resultBlock];
}

+ (id)alertWithTitle:(NSString *)title
             message:(NSString *)message
   cancelButtonTitle:(NSString *)cancelButton
   otherButtonTitles:(NSArray*)otherButtonTitles
          controller:(UIViewController *)controller
         resultBlock:(AMAlertCompletionBlock)resultBlock {
    return [self alertWithTitle:title message:message initialText:nil cancelButtonTitle:cancelButton textField:NO disableButton:NO secured:NO otherButtonTitles:otherButtonTitles controller:controller resultBlock:resultBlock];
}

+ (id)textFieldAlertWithTitle:(NSString *)title
                      message:(NSString *)message
                  initialText:(NSString *)initialText
            cancelButtonTitle:(NSString *)cancelButton
                      secured:(BOOL)secured
            otherButtonTitles:(NSArray *)otherButtonTitles
                   controller:(UIViewController *)controller
                  resultBlock:(AMAlertTextCompletionBlock)resultBlock {
    return [self alertWithTitle:title message:message initialText:initialText cancelButtonTitle:cancelButton textField:YES disableButton:YES secured:secured otherButtonTitles:otherButtonTitles controller:controller resultBlock:resultBlock];
}

+ (id)textFieldAlertWithTitle:(NSString *)title
                      message:(NSString *)message
                  initialText:(NSString *)initialText
            cancelButtonTitle:(NSString *)cancelButton
                      secured:(BOOL)secured
            otherButtonTitles:(NSArray *)otherButtonTitles
                  resultBlock:(AMAlertTextCompletionBlock)resultBlock {
    return [self alertWithTitle:title message:message initialText:initialText cancelButtonTitle:cancelButton textField:YES disableButton:YES secured:secured otherButtonTitles:otherButtonTitles controller:nil resultBlock:resultBlock];
}

+ (id)alertWithTitle:(NSString *)title
             message:(NSString *)message
         initialText:(NSString *)initialText
   cancelButtonTitle:(NSString *)cancelButton
           textField:(BOOL)textField
       disableButton:(BOOL)disableButton
             secured:(BOOL)secured
   otherButtonTitles:(NSArray *)otherButtonTitles
          controller:(UIViewController *)controller
         resultBlock:(id)resultBlock {
	
	if ([UIAlertController class]) {
		
		NSInteger cancelButtonIndex = (cancelButton != nil) - 1;
		NSInteger firstOtherButtonIndex = cancelButtonIndex + 1;
		
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
		__weak typeof(alertController) weakController = alertController;
		
		void(^block)(NSInteger) = ^(NSInteger buttonIndex){
			if (resultBlock) {
				if (!textField) {
					AMAlertCompletionBlock completionBlock = resultBlock;
					completionBlock(cancelButtonIndex, firstOtherButtonIndex, buttonIndex);
				} else {
					AMAlertTextCompletionBlock completionBlock = resultBlock;
					completionBlock(cancelButtonIndex, firstOtherButtonIndex, buttonIndex, [[weakController textFields][0] text]);
				}
			}
		};
		
		if (cancelButton) {
			UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButton style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
				block(cancelButtonIndex);
			}];
			[alertController addAction:cancelAction];
		}
		
        UIAlertAction *lastAction = nil;
		for (NSString *title in otherButtonTitles) {
			UIAlertAction *otherAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
				block(firstOtherButtonIndex + [otherButtonTitles indexOfObject:title]);
			}];
			[alertController addAction:otherAction];
            lastAction = otherAction;
		}
		
		if (textField) {
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
				textField.secureTextEntry = secured;
                textField.text = initialText;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                
                if (disableButton && lastAction) {
                    lastAction.enabled = initialText.length;
                    [textField addTarget:[self shared] action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    objc_setAssociatedObject(textField, kAMAlertViewAction, lastAction, OBJC_ASSOCIATION_ASSIGN);
                }
			}];
		}
		
		if (!controller && [UIApplication respondsToSelector:@selector(sharedApplication)]) {
			controller = [self findRootViewController];
		}
		
		[controller presentViewController:alertController animated:YES completion:nil];
        return alertController;
	} else {
		
		UIAlertView *alertView = [[UIAlertView alloc] init];
		alertView.message = message;
		alertView.title = title;
		alertView.delegate = resultBlock ? [AMAlertView shared] : nil;
		[alertView addButtonWithTitle:cancelButton];
		alertView.cancelButtonIndex = 0;
		
		for (NSString *title in otherButtonTitles) {
			[alertView addButtonWithTitle:title];
		}
		alertView.alertViewStyle = textField ? (secured ? UIAlertViewStyleSecureTextInput : UIAlertViewStylePlainTextInput) : UIAlertViewStyleDefault;
		if (resultBlock) {
			objc_setAssociatedObject(alertView, kAMAlertViewBlock, resultBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
		[alertView show];
        return alertView;
	}
}

+ (UIViewController *)findRootViewController {
	UIApplication *sharedApplication = [UIApplication valueForKey:@"sharedApplication"];
	UIViewController *controller = sharedApplication.keyWindow.rootViewController;
	
	while (controller.presentedViewController) {
		controller = controller.presentedViewController;
	}
	return controller;
}

+ (id)actionSheetWithTitle:(NSString *)title
         cancelButtonTitle:(NSString *)cancelButton
    destructiveButtonIndex:(NSInteger)destructiveIndex
         otherButtonTitles:(NSArray *)otherButtonTitles
                      view:(UIView *)view
                      rect:(CGRect)rect
               resultBlock:(AMActionSheetCompletionBlock)resultBlock {
    return [self actionSheetWithTitle:title cancelButtonTitle:cancelButton destructiveButtonIndex:destructiveIndex otherButtonTitles:otherButtonTitles view:view rect:rect barButtonItem:nil controller:nil resultBlock:resultBlock];
}

+ (id)actionSheetWithTitle:(NSString *)title
         cancelButtonTitle:(NSString *)cancelButton
    destructiveButtonIndex:(NSInteger)destructiveIndex
         otherButtonTitles:(NSArray *)otherButtonTitles
                      view:(UIView *)view
                      rect:(CGRect)rect
                controller:(UIViewController *)controller
               resultBlock:(AMActionSheetCompletionBlock)resultBlock {
    return [self actionSheetWithTitle:title cancelButtonTitle:cancelButton destructiveButtonIndex:destructiveIndex otherButtonTitles:otherButtonTitles view:view rect:rect barButtonItem:nil controller:controller resultBlock:resultBlock];
}

+ (id)actionSheetWithTitle:(NSString *)title
         cancelButtonTitle:(NSString *)cancelButton
    destructiveButtonIndex:(NSInteger)destructiveIndex
         otherButtonTitles:(NSArray *)otherButtonTitles
             barButtonItem:(UIBarButtonItem *)barButtonItem
               resultBlock:(AMActionSheetCompletionBlock)resultBlock {
    return [self actionSheetWithTitle:title cancelButtonTitle:cancelButton destructiveButtonIndex:destructiveIndex otherButtonTitles:otherButtonTitles view:nil rect:CGRectZero barButtonItem:barButtonItem controller:nil resultBlock:resultBlock];
}

+ (id)actionSheetWithTitle:(NSString *)title
         cancelButtonTitle:(NSString *)cancelButton
    destructiveButtonIndex:(NSInteger)destructiveIndex
         otherButtonTitles:(NSArray *)otherButtonTitles
             barButtonItem:(UIBarButtonItem *)barButtonItem
                controller:(UIViewController *)controller
               resultBlock:(AMActionSheetCompletionBlock)resultBlock {
    return [self actionSheetWithTitle:title cancelButtonTitle:cancelButton destructiveButtonIndex:destructiveIndex otherButtonTitles:otherButtonTitles view:nil rect:CGRectZero barButtonItem:barButtonItem controller:controller resultBlock:resultBlock];
}

+ (id)actionSheetWithTitle:(NSString *)title
         cancelButtonTitle:(NSString *)cancelButton
    destructiveButtonIndex:(NSInteger)destructiveIndex
         otherButtonTitles:(NSArray *)otherButtonTitles
                      view:(UIView *)view
                      rect:(CGRect)rect
             barButtonItem:(UIBarButtonItem *)barButtonItem
                controller:(UIViewController *)controller
               resultBlock:(AMActionSheetCompletionBlock)resultBlock {
	
	if ([UIAlertController class]) {
		
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
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (view != nil) {
                alertController.popoverPresentationController.sourceRect = rect;
                alertController.popoverPresentationController.sourceView = view;
            }
            else if(barButtonItem != nil) {
                alertController.popoverPresentationController.barButtonItem = barButtonItem;
            }
		}
		
        if (controller == nil) {
            UIResponder *responder = view;
            while (![responder isKindOfClass:[UIViewController class]]) {
                responder = [responder nextResponder];
                if (nil == responder) {
                    break;
                }
            }
            controller = (UIViewController*)responder;
            
            if (!controller && [UIApplication respondsToSelector:@selector(sharedApplication)]) {
                controller = [self findRootViewController];
            }
        }
		
		[controller presentViewController:alertController animated:YES completion:nil];
        return alertController;
        
	} else {
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
		actionSheet.title = title;
		actionSheet.delegate = resultBlock ? [AMAlertView shared] : nil;
		
		for (NSString *title in otherButtonTitles) {
			[actionSheet addButtonWithTitle:title];
		}
		actionSheet.destructiveButtonIndex = destructiveIndex;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && !CGRectIsEmpty(rect)) {
			[actionSheet showFromRect:rect inView:view animated:YES];
		} else if (barButtonItem != nil) {
            [actionSheet showFromBarButtonItem:barButtonItem animated:YES];
        } else {
			[actionSheet showInView:view];
		}
		
		if (cancelButton) {
			[actionSheet addButtonWithTitle:cancelButton];
			actionSheet.cancelButtonIndex = otherButtonTitles.count;
		}
		
		if (resultBlock) {
			objc_setAssociatedObject(actionSheet, kAMAlertViewBlock, resultBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
        return actionSheet;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	id block = objc_getAssociatedObject(alertView, kAMAlertViewBlock);
	if (alertView.alertViewStyle == UIAlertViewStyleDefault) {
		AMAlertCompletionBlock resultBlock = block;
		resultBlock(alertView.cancelButtonIndex, alertView.cancelButtonIndex + 1, buttonIndex);
	} else {
		AMAlertTextCompletionBlock resultBlock = block;
		resultBlock(alertView.cancelButtonIndex, alertView.cancelButtonIndex + 1, buttonIndex, [[alertView textFieldAtIndex:0] text]);
	}
	objc_removeAssociatedObjects(alertView);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	AMActionSheetCompletionBlock block = objc_getAssociatedObject(actionSheet, kAMAlertViewBlock);
	block(actionSheet.destructiveButtonIndex, actionSheet.cancelButtonIndex, actionSheet.firstOtherButtonIndex, buttonIndex);
	objc_removeAssociatedObjects(actionSheet);
}

- (void)textFieldDidChange:(UITextField *)sender {
    UIAlertAction *lastAction = objc_getAssociatedObject(sender, kAMAlertViewAction);
    lastAction.enabled = sender.text.length;
}

@end
