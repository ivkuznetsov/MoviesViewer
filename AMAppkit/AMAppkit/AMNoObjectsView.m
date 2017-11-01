//
//  AMNoObjectsView.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMNoObjectsView.h"

@implementation AMNoObjectsView

- (void)setActionBlock:(dispatch_block_t)actionBlock {
    _actionBlock = actionBlock;
    _actionButton.hidden = _actionBlock == nil;
}

- (IBAction)buttonAction:(id)sender {
    _actionBlock();
}

@end
