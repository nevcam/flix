//
//  MoviesViewController.m
//  flix
//
//  Created by nev on 6/26/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (strong, nonatomic) NSArray *filteredMovies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    [self.activityIndicator startAnimating];
    [self fetchMovies];
    
    // Customize Navigation Bar
    self.navigationItem.title = @"Movies";
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.barTintColor = [UIColor darkGrayColor];
    navigationBar.tintColor = [UIColor whiteColor];
    navigationBar.translucent = NO;
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    shadow.shadowOffset = CGSizeMake(1, 1);
    shadow.shadowBlurRadius = 3;
    navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName : [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:0.8], NSShadowAttributeName : shadow};
    
    // Refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
}

- (void)fetchMovies {
    
    // Get data from API
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Stop activity indicator
        [self.activityIndicator stopAnimating];

        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            
            // if there is a network error, create an alert controller
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Error" message:@"Cannot get movies! The internet connection appears to be offline." preferredStyle:(UIAlertControllerStyleAlert)];
            
            // create a try again action
            UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
                    // function calls itself to try again!
                    [self fetchMovies];
                }];
            // add the cancel action to the alertController
            [alert addAction:tryAgainAction];

            [self presentViewController:alert animated:YES completion:^{
                // function calls itself after the alert controller has finished presenting
//                [self fetchMovies];
            }];
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.movies = dataDictionary[@"results"];
            self.filteredMovies = self.movies;
            
            // Reload table view after fetching the data
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
    [task resume];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //prototype cell
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    
    // Set labels
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    NSString* rating = [NSString stringWithFormat:@"%@", movie[@"vote_average"]];
    cell.ratingLabel.text = rating;
    cell.ratingLabel.backgroundColor = [UIColor colorWithRed:0.1 green:0.45 blue:0.1 alpha:0.8];
    cell.ratingLabel.layer.cornerRadius = 10.0;
    cell.ratingLabel.clipsToBounds = true;
    
    // URL for poster view
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    // checks if it's a valid URL
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    // Uncomment next line to change cell selection style
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = UIColor.darkGrayColor;
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
    }
    else {
        self.filteredMovies = self.movies;
    }
    [self.tableView reloadData];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    //
    [self fetchMovies];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    // get the indexPath for the tapped cell
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    // get the tapped movie using the indexPath for the tapped cell
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    // to hand the movie : get the new view controller using [segue destinationViewController] and cast it
    DetailsViewController *detailsViewController = [segue destinationViewController];
    
    detailsViewController.movie = movie;
}


@end
