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
@property (nonatomic) AMOperationHelper *operationHelper;

@end

@implementation MovieCell

- (void)awakeFromNib {
    [super awakeFromNib];
    __weak typeof(self) wSelf = self;
    [NSManagedObject addObserver:self block:^(AMNotification *not) {
        if ([not.updated containsObject:wSelf.movie.permanentObjectID.URIRepresentation]) {
            [wSelf reloadView];
            if (wSelf.window) {
                [wSelf addFadeTransition];
            }
        }
    } classes:@[[Movie class]]];
    _operationHelper = [[AMOperationHelper alloc] initWithView:self];
}

- (void)reloadView {
    _titleLabel.text = _movie.title;
    __weak typeof(self) weakSelf = self;
    
    _posterImageView.image = [UIImage imageNamed:@"placeholder"];
    Movie *movie = _movie;
    [_movie fullPosterPath:^(NSString *path, NSError *error) {
        if (!error) {
            [weakSelf.posterImageView sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (weakSelf.movie == movie && image && cacheType == SDImageCacheTypeNone) {
                    [weakSelf.posterImageView addFadeTransition];
                }
            }];
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
        
        [self.operationHelper runBlock:^(AMCompletion completion, AMHandleOperation operation, AMProgress progress) {
            
            operation([movie updateDetails:completion]);
            
        } completion:^(id object, NSError *requestError) {
            if (requestError.code == NSURLErrorNotConnectedToInternet && weakSelf.movie == movie) {
                [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(didChangeReachabilityStatus) name:kReachabilityChangeNotification object:nil];
                weakSelf.failedUpdatingId = movie.permanentObjectID;
            }
        } loading:AMLoadingTypeNone key:@"details"];
    }
}

+ (CGSize)sizeForContentWidth:(CGFloat)width space:(CGFloat)space {
    width = width - space * 2.0;
    
    NSUInteger count = floor(width / 150.0);
    NSUInteger side = (width - space * (count - 1)) / count;
    
    return CGSizeMake(side, [self heightForWidth:side]);
}

+ (CGFloat)heightForWidth:(CGFloat)width {
    CGFloat height = (width - 16.0) / 3.0 * 4.0;
    height += 53;
    return height;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangeNotification object:nil];
}

@end
