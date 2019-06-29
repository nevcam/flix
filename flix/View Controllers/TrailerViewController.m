//
//  TrailerViewController.m
//  flix
//
//  Created by nev on 6/28/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "TrailerViewController.h"

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *trailerWebView;
@property (nonatomic, strong) NSDictionary *movieData;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *baseString = @"https://api.themoviedb.org/3/movie/";
//    NSString *idString = self.movieToPass[@"id"];
    NSString* idString = [NSString stringWithFormat:@"%@", self.movieToPass[@"id"]];
    NSLog(@"MOVIE ID THAT WAS PASSED: %@", idString);
    NSString *withID = [baseString stringByAppendingString:idString];
    NSString *key = @"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString = [withID stringByAppendingString:key];
    // Convert the url String to a NSURL object.
    NSURL *urlToGet = [NSURL URLWithString:urlString];
    NSLog(@"MOVIE URL: %@", urlToGet);

    NSURLRequest *request = [NSURLRequest requestWithURL:urlToGet cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//
            self.movieData = dataDictionary[@"results"][0];
            NSLog(@"MOVIE DATA: %@", self.movieData);
            
//            NSDictionary *movieTrailer = self.movieData[0];

            NSString *baseURLString = @"https://www.youtube.com/watch?v=";
            NSString *keyString = self.movieData[@"key"];
            NSString *fullURL = [baseURLString stringByAppendingString:keyString];
//
//            // Convert the url String to a NSURL object.
            NSURL *urlTrailer = [NSURL URLWithString:fullURL];
//
//
//            // Place the URL in a URL Request.
            NSURLRequest *requestTrailer = [NSURLRequest requestWithURL:urlTrailer cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
//            // Load Request into WebView.
            [self.trailerWebView loadRequest:requestTrailer];
        }
    }];
    [task resume];
    
    
//     Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
