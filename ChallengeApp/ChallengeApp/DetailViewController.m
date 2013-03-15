//
//  DetailViewController.m
//  ChallengeApp
//
//  Created by Tony on 3/10/13.
//  Copyright (c) 2013 Subfuzion. All rights reserved.
//

#import "DetailViewController.h"
#import "ChallengeAPI.h"

@interface DetailViewController ()

- (IBAction)onSendAction:(id)sender;
- (IBAction)onBookmarkAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property(weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property(weak, nonatomic) IBOutlet UILabel *bookmarkLabel;

- (void)configureView;

@end

@implementation DetailViewController {
    NSOperationQueue *_backgroundOperationQueue;
    NSOperation *_fetchImageOperation;
    ChallengeAPI *_challengeAPI;
}

#pragma mark - Managing the detail item

- (void)configureView {
    // Update the user interface for the challenge, which is passed by MasterViewController
    Challenge *item = self.challenge;
    if (item) {
        self.titleLabel.text = item.title;
        self.detailDescriptionLabel.text = item.description;
  
        // load image asynchronously
        [self fetchImage:item.imageURL useOperationQueue:_backgroundOperationQueue];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _bookmarkLabel.hidden = YES;

    if (!_backgroundOperationQueue) {
        _backgroundOperationQueue = [[NSOperationQueue alloc] init];
    }
    
    if (!_challengeAPI) {
        _challengeAPI = [[ChallengeAPI alloc] init];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSendAction:(id)sender {

    NSString *message = @"I want to share this challenge.gov posting with you.";

    Challenge *item = self.challenge;
    
    NSArray *postItems = @[message,item.url];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
          initWithActivityItems:postItems
            applicationActivities:nil];

    activityVC.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact];

    [self presentViewController:activityVC animated:YES completion:nil];

}

- (IBAction)onBookmarkAction:(UIButton *)sender {

    //add id to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *bookmarks = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"bookmarkArray"]];

    //see if id already added before, don't store it if already there
    NSString *id = self.challenge.ID;
    if (![bookmarks containsObject:id]) {
        [bookmarks addObject:id];
    }

    [defaults setObject:bookmarks forKey:@"bookmarkArray"];

    [defaults synchronize];


    //fade in and out label that says "bookmarked"
    _bookmarkLabel.alpha = 0;
    _bookmarkLabel.hidden = NO;

    [UIView animateWithDuration:0.3 animations:^{
        _bookmarkLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            _bookmarkLabel.alpha = 0;
        }];
    }];
}

- (void)fetchImage:(NSString *)imageURL useOperationQueue:(NSOperationQueue *)operationQueue {
    // remove any previous images (from cell reuse) while image is downloading
    self.logoImageView.image = nil;
    
    _fetchImageOperation = [ChallengeAPI fetchImage:imageURL operationQueue:operationQueue withBlock:^(UIImage *image) {
        self.logoImageView.image = image;
    }];
}

- (void)cancelUpdate {
    if (_fetchImageOperation) {
        [_fetchImageOperation cancel];
    }
    self.logoImageView.image = nil;
}
@end
