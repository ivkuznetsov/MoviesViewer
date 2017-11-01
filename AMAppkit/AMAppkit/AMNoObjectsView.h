//
//  AMNoObjectsView.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBorderedButton.h"

@interface AMNoObjectsView : UIView

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailsLabel;
@property (nonatomic, weak) IBOutlet AMBorderedButton *actionButton;
@property (nonatomic) dispatch_block_t actionBlock;

@end
