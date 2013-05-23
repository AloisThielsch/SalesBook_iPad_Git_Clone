//
//  SAGViewController.h
//  SalesBook
//
//  Created by Andreas Kucher on 13.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SAGSyncManager.h"

@interface SyncManagerViewController : UIViewController <SAGSyncManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblCurrentState;
@property (weak, nonatomic) IBOutlet UIProgressView *barCurrentState;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTaskState;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UIButton *btnDismiss;

- (IBAction)actionContinueSync:(id)sender;
- (IBAction)actionDismiss:(UIButton *)sender;

@end
