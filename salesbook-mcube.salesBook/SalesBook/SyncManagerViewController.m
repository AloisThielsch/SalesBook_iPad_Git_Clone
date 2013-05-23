//
//  SAGViewController.m
//  SalesBook
//
//  Created by Andreas Kucher on 13.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import "SyncManagerViewController.h"

#import "SAGLoginManager.h"

@interface SyncManagerViewController ()

@end

@implementation SyncManagerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[SAGSyncManager sharedClient] setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![[SAGLoginManager sharedManger] isDatabaseOpen])
    {
        [self dismissSyncUI];
    }
    
    [_btnDismiss setTitle:NSLocalizedString(@"Close", @"Close") forState:UIControlStateNormal];
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)syncManagerLocalizedTaskNameChanged:(NSString *)text
{
    _lblCurrentState.text = text;
}

- (void)syncManagerLocalizedTaskStatusChanged:(NSString *)text
{
    _lblCurrentTaskState.text = text;
}

- (void)syncManagerLocalizedErrorMessage:(NSAttributedString *)text
{
    if ([text length] == 0)
    {
        return;
    }
    if ([_myTextView.attributedText length] != 0)
    {
        NSMutableAttributedString *att = [NSMutableAttributedString new];
        [att appendAttributedString:_myTextView.attributedText];
        [att appendAttributedString:text];
        
        _myTextView.attributedText = att;
    }
    else
    {
        _myTextView.attributedText = text;
    }
    
    [_myTextView scrollRangeToVisible:NSMakeRange([_myTextView.text length], 0)];
}

- (void)syncManagerSetContinueButtonText:(NSString *)text
{
    [_btnContinue setTitle:text forState:UIControlStateNormal];
}

- (void)syncManagerUpdateProgressValue:(NSNumber *)progress
{    
    [_barCurrentState setProgress:[progress floatValue]];
}

- (void)syncManagerIsSynchronisationPaused:(NSNumber *)isRunnung
{
    _btnContinue.hidden = !isRunnung.boolValue;
}

- (void)syncManagerIsSynchronisationRunning:(NSNumber *)isRunnung
{    
    if (isRunnung.boolValue)
    {
        _myTextView.text = @""; //Aufräumen
        _btnDismiss.hidden = YES;
        _barCurrentState.hidden = NO;
        
        [_activityIndicator startAnimating];
    }
    else
    {
        _btnDismiss.hidden = NO;
        _btnContinue.hidden = YES;
        _barCurrentState.hidden = YES;
        [_activityIndicator stopAnimating];

        //[self performSelectorInBackground:@selector(enableCountdown) withObject:nil]; //Countdown und automatisches schliessen...
    }
}

- (IBAction)actionContinueSync:(id)sender
{
    [[SAGSyncManager sharedClient] continueSynchronization];
}

- (IBAction)actionDismiss:(UIButton *)sender
{
    [self dismissSyncUI];
}

- (void)dismissSyncUI
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationSynchronizationDone object:nil];
        
        DDLogInfo(@"Dismiss SyncManagerUI!");
    }];
}

#pragma mark - CountDown

- (void)enableCountdown
{
    for (int i = 30; i > 0; i--)
    {
        [self performSelectorOnMainThread:@selector(updateDismissButtonWithNumber:)
                               withObject:[NSNumber numberWithInt:i] waitUntilDone:YES];
        sleep(1);
    }
    
    [self performSelectorOnMainThread:@selector(dismissSyncUI) withObject:nil waitUntilDone:NO];
}

- (void)updateDismissButtonWithNumber:(NSNumber *)number
{
    [_btnDismiss setTitle:[NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"Close", @"Close"), number.intValue] forState:UIControlStateNormal];
}

@end
