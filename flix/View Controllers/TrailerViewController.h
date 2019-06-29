//
//  TrailerViewController.h
//  flix
//
//  Created by nev on 6/28/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrailerViewController : UIViewController
- (IBAction)backButton:(id)sender;
@property (nonatomic, strong) NSDictionary *movieToPass;

@end

NS_ASSUME_NONNULL_END
