//
//  DetailsViewController.m
//  flix
//
//  Created by nev on 6/26/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
//@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = self.movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    // checks if it's a valid URL
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    [self.posterView setImageWithURL:posterURL];

    NSString *backdropURLString = self.movie[@"backdrop_path"];
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString];
    [self.backdropView setImageWithURL:backdropURL];
    
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
//    self.dateLabel.text = self.movie[@"release_date"];
    NSString* rating = [NSString stringWithFormat:@"%@", self.movie[@"vote_average"]];
    self.ratingLabel.text = rating;
    self.ratingLabel.backgroundColor = [UIColor colorWithRed:0.1 green:0.45 blue:0.1 alpha:0.8];
    self.ratingLabel.layer.cornerRadius = 10.0;
    self.ratingLabel.clipsToBounds = true;
    
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSDictionary *movieToPass = self.movie;
    // to hand the movie : get the new view controller using [segue destinationViewController] and cast it
    TrailerViewController *trailerViewController = [segue destinationViewController];
    
    trailerViewController.movieToPass = movieToPass;
}


@end
