//
//  LoginManagerViewController.h
//  SalesBook
//
//  Created by Andreas Kucher on 06.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "SAGLoginManager.h"

@class DragDropCrane;

@interface LoginManagerViewController : UIViewController <SAGLoginManagerDelegate, UITextFieldDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtStartCode;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *btnChangeState;
@property (weak, nonatomic) IBOutlet UIImageView *imgCheckEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnSyncronize;

@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
@property (weak, nonatomic) IBOutlet UILabel *lblLastSync;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnMenue;
@property (weak, nonatomic) IBOutlet UIButton *btnMediaDownload;

@property (strong, nonatomic) IBOutletCollection(UISwipeGestureRecognizer) NSArray *swipeRecognizers;

- (IBAction)changeState:(UIButton *)sender;
- (IBAction)changePage:(UIPageControl *)sender;

- (IBAction)deleteUser:(UIButton *)sender;
- (IBAction)syncronizeData:(UIButton *)sender;
- (IBAction)toggelMediaDownload:(UIButton *)sender;

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender;
- (IBAction)swipeRight:(UISwipeGestureRecognizer *)sender;

- (IBAction)doJulian:(id)sender;
- (IBAction)doAndy:(id)sender;
- (IBAction)revealMenu:(id)sender;
- (IBAction)revealUnderRight:(id)sender;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *developerButtons;


@end