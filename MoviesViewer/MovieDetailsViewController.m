//
//  MovieDetailsViewController.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "NSMutableArray+Validation.h"
#import "FavouritesItem.h"

@interface MovieDetailsViewController ()

@property (nonatomic) Movie *movie;
@property (nonatomic, weak) IBOutlet UIImageView *posterImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtiteLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *propertiesLabel;

@end

@implementation MovieDetailsViewController

- (instancetype)initWithMovie:(Movie *)movie {
    if (self = [super init]) {
        _movie = movie;
        [Movie addObserver:self selector:@selector(didGetUpdate:)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeReachabilityStatus) name:kReachabilityChangeNotification object:nil];
    }
    return self;
}

- (void)didChangeReachabilityStatus {
    if (!_movie.isLoaded) {
        [self updateMovie];
    }
}

- (void)updateMovie {
    [self runBlock:^(CompletionBlock completion, HandleOperation handleOperation) {
        
        handleOperation([_movie updateDetailsWithCompletion:completion]);
        
    } completion:nil loading:[_movie isLoaded] ? LoadingTypeNone : LoadingTypeFull errorType:[_movie isLoaded] ? ErrorTypeNone : ErrorTypeFull];
    [self reloadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateMovie];
    self.navigationItem.rightBarButtonItem = [[FavouritesItem alloc] initWithMovie:_movie];
}

- (void)didGetUpdate:(NSNotification *)notification {
    if (notification.object == _movie.permanentObjectID) {
        [self reloadView];
    }
}

- (void)reloadView {
    _titleLabel.text = _movie.title;
    
    NSMutableArray *sublineComponents = [NSMutableArray array];
    [sublineComponents addValidObject:_movie.rated];
    [sublineComponents addValidObject:_movie.runtime];
    [sublineComponents addValidObject:_movie.genre];
    [sublineComponents addValidObject:_movie.released];
    [sublineComponents addValidObject:_movie.country];
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.3 alpha:1.0] };
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@""];
    for (NSString *component in sublineComponents) {
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[component stringByReplacingOccurrencesOfString:@" " withString:@" "] attributes:attributes]]; //replaces spaces with no-break spaces
        if (sublineComponents.lastObject != component) {
            [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"  |  " attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.3 alpha:0.2] }]];
        }
    }
    _subtiteLabel.attributedText = attrString;
    _descriptionLabel.text = _movie.plot;
    
    attrString = [[NSMutableAttributedString alloc] initWithString:@""];
    CGFloat flontHeight = self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular ? 18 : 15;
    [self attachValue:_movie.director label:@"Director: " toAttrString:attrString newLine:NO fontHeight:flontHeight];
    [self attachValue:_movie.writer label:@"Writers: " toAttrString:attrString newLine:YES fontHeight:flontHeight];
    [self attachValue:_movie.actors label:@"Stars: " toAttrString:attrString newLine:YES fontHeight:flontHeight];
    _propertiesLabel.attributedText = attrString;
    
    __weak typeof(self) weakSelf = self;
    [_posterImageView setImageWithURL:[NSURL URLWithString:_movie.poster] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image && cacheType == SDImageCacheTypeNone) {
            [weakSelf.posterImageView addFadeTransition];
        }
    }];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self reloadView];
}

- (void)attachValue:(NSString *)value label:(NSString *)label toAttrString:(NSMutableAttributedString *)string newLine:(BOOL)newLine fontHeight:(CGFloat)fontHeight {
    if (!value.length) {
        return;
    }
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:newLine ? [@"\n" stringByAppendingString:label] : label attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.1 alpha:1.0], NSFontAttributeName : [UIFont boldSystemFontOfSize:fontHeight] }]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:value attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.3 alpha:1.0], NSFontAttributeName : [UIFont systemFontOfSize:fontHeight] }]];
}

- (void)dealloc {
    [Movie removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangeNotification object:nil];
}

@end
