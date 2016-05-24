//
//  MovieCell.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "MovieCell.h"
#import "UIImageView+WebCache.h"

@interface MovieCell()

@property (nonatomic, weak) IBOutlet UIImageView *posterImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic) NSManagedObjectID *failedUpdatingId;

@end

@implementation MovieCell

- (void)awakeFromNib {
    [Movie addObserver:self selector:@selector(didGetUpdate:)];
}

- (void)didGetUpdate:(NSNotification *)notification {
    if (notification.object == _movie.permanentObjectID) {
        [self reloadView];
        if (self.window) {
            [self addFadeTransition];
        }
    }
}

- (void)reloadView {
    _titleLabel.text = _movie.title;
    __weak typeof(self) weakSelf = self;
    [_posterImageView setImageWithURL:[NSURL URLWithString:_movie.poster] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image && cacheType == SDImageCacheTypeNone) {
            [weakSelf.posterImageView addFadeTransition];
        }
    }];
}

- (void)setMovie:(Movie *)movie {
    _movie = movie;
    _failedUpdatingId = nil;
    [self reloadView];
    [self updateDetailsIfNeeded];
}

- (void)didChangeReachabilityStatus {
    if (_failedUpdatingId == _movie.permanentObjectID) {
        _failedUpdatingId = nil;
        [self updateDetailsIfNeeded];
    }
}

- (void)updateDetailsIfNeeded {
    if ((!_movie.title || !_movie.poster) && !_movie.isLoaded) {
        __weak typeof(self) weakSelf = self;
        Movie *movie = _movie;
        [_movie updateDetailsWithCompletion:^(id request, NSError *error) {
            if (error.code == NSURLErrorNotConnectedToInternet && weakSelf.movie == movie) {
                [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(didChangeReachabilityStatus) name:kReachabilityChangeNotification object:nil];
                weakSelf.failedUpdatingId = movie.permanentObjectID;
            }
        }];
    }
}

+ (CGSize)sizeForContentWidth:(CGFloat)width {
    CGFloat k = [[UIApplication sharedApplication] keyWindow].traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular ? 1.5 : 1.0;
    CGFloat defaultWidth = 135.0 * k;
    
    CGFloat cellWidth = width / floor(width / defaultWidth);
    return CGSizeMake(floor(cellWidth), floor(cellWidth * 1.3));
}

- (void)dealloc {
    [Movie removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangeNotification object:nil];
}

@end