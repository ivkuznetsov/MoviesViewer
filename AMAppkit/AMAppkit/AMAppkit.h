//
//  AMAppkit.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 25/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for AMAppkit.
FOUNDATION_EXPORT double AMAppkitVersionNumber;

//! Project version string for AMAppkit.
FOUNDATION_EXPORT const unsigned char AMAppkitVersionString[];

#import <AMAppkit/AMBaseViewController.h>
#import <AMAppkit/UIView+LoadingFromFrameworkNib.h>
#import <AMAppkit/AMAppearance.h>
#import <AMAppkit/AMAppearanceSupportObject.h>
#import <AMAppkit/AMAppkitDefines.h>

//tools
#import <AMAppkit/AMAlertView.h>
#import <AMAppkit/AMUtils.h>

#import <AMAppkit/SDWebImage/UIImageView+WebCache.h>
#import <AMAppkit/SDWebImage/UIButton+WebCache.h>
#import <AMAppkit/SDWebImage/MKAnnotationView+WebCache.h>

//operation helper
#import <AMAppkit/AMOperationHelper.h>
#import <AMAppkit/AMFailedView.h>
#import <AMAppkit/AMLoadingView.h>
#import <AMAppkit/AMCircularProgressView.h>
#import <AMAppkit/AMLoadingBarView.h>
#import <AMAppkit/AMAlertBarView.h>

//table helper
#import <AMAppkit/AMTableHelper.h>
#import <AMAppkit/AMBaseTableViewCell.h>
#import <AMAppkit/AMNoObjectsView.h>
#import <AMAppkit/UITableView+Reloading.h>
#import <AMAppkit/UITableViewCell+Additions.h>

//paging table helper
#import <AMAppkit/AMFooterLoadingView.h>
#import <AMAppkit/AMPagingLoader.h>
#import <AMAppkit/AMPagingTableHelper.h>

//collection helper
#import <AMAppkit/AMCollectionHelper.h>
#import <AMAppkit/AMCollectionView.h>
#import <AMAppkit/AMContainerCell.h>
#import <AMAppkit/UICollectionView+Reloading.h>
#import <AMAppkit/AMCollectionViewLeftAlignedLayout.h>
#import <AMAppkit/AMPagingCollectionHelper.h>

//notifications
#import <AMAppkit/AMNotificationManager.h>
#import <AMAppkit/AMNotification.h>
#import <AMAppkit/AMObservable.h>
#import <AMAppkit/NSManagedObject+Notifications.h>

//custom views
#import <AMAppkit/AMBorderedButton.h>
#import <AMAppkit/AMSeparatorView.h>
#import <AMAppkit/AMFadeButton.h>

//additions
#import <AMAppkit/UIView+Frame.h>
#import <AMAppkit/UIImage+Tint.h>
#import <AMAppkit/UIView+SSToolkitAdditions.h>
#import <AMAppkit/NSObject+ClassName.h>
#import <AMAppkit/NSArray+Validation.h>
#import <AMAppkit/NSString+Validation.h>
