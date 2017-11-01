//
//  MovieDetailsViewController.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "MovieDetailsViewController.h"
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
        
        __weak typeof(self) wSelf = self;
        [NSManagedObject addObserver:self block:^(AMNotification *not) {
            if ([not.updated containsObject:wSelf.movie.permanentObjectID.URIRepresentation]) {
                [wSelf reloadView];
            }
        } classes:@[[Movie class]]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeReachabilityStatus) name:kReachabilityChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.operationHelper = [[AMOperationHelper alloc] initWithView:self.view];
    [self updateMovie];
    self.navigationItem.rightBarButtonItem = [[FavouritesItem alloc] initWithMovie:_movie container:AppContainer.shared.favorites];
}

- (void)didChangeReachabilityStatus {
    if (!_movie.isLoaded) {
        [self updateMovie];
    }
}

- (void)updateMovie {
    [self.operationHelper runBlock:^(AMCompletion completion, AMHandleOperation operation, AMProgress progress) {
        
        operation([_movie updateDetails:completion]);
        
    } completion:nil loading:[_movie isLoaded] ? AMLoadingTypeNone : AMLoadingTypeFullscreen key:@"update"];
    [self reloadView];
}

- (void)reloadView {
    _titleLabel.text = _movie.title;
    
    NSMutableArray *sublineComponents = [NSMutableArray array];
    [sublineComponents addValidObject:_movie.rated];
    [sublineComponents addValidObject:_movie.runtime];
    
    if (_movie.genres.count) {
        [sublineComponents addValidObject:[_movie.genres componentsJoinedByString:@", "]];
    }
    [sublineComponents addValidObject:_movie.released];
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.3 alpha:1.0] };
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@""];
    for (NSString *component in sublineComponents) {
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[component stringByReplacingOccurrencesOfString:@" " withString:@" "] attributes:attributes]]; //replaces spaces with no-break spaces
        if (sublineComponents.lastObject != component) {
            [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"  |  " attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.3 alpha:0.2] }]];
        }
    }
    _subtiteLabel.attributedText = attrString;
    _descriptionLabel.text = _movie.overview;
    
    attrString = [[NSMutableAttributedString alloc] initWithString:@""];
    CGFloat flontHeight = 16;
    [self attachValue:[_movie.countries componentsJoinedByString:@", "] label:@"Countries: " toAttrString:attrString newLine:NO fontHeight:flontHeight];
    [self attachValue:[_movie.companies componentsJoinedByString:@", "] label:@"Companies: " toAttrString:attrString newLine:YES fontHeight:flontHeight];
    _propertiesLabel.attributedText = attrString;
    
    __weak typeof(self) weakSelf = self;
    [_movie fullPosterPath:^(NSString *parh, NSError *error) {
        if (!error && weakSelf) {
            [weakSelf.posterImageView sd_setImageWithURL:[NSURL URLWithString:parh] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image && cacheType == SDImageCacheTypeNone) {
                    [weakSelf.posterImageView addFadeTransition];
                }
            }];
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
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:(newLine && string.length) ? [@"\n\n" stringByAppendingString:label] : label attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.1 alpha:1.0], NSFontAttributeName : [UIFont boldSystemFontOfSize:fontHeight] }]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:value attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.3 alpha:1.0], NSFontAttributeName : [UIFont systemFontOfSize:fontHeight] }]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangeNotification object:nil];
}

@end
