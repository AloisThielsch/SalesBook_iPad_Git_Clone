//
//  LoginManagerViewController.m
//  SalesBook
//
//  Created by Andreas Kucher on 06.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "LoginManagerViewController.h"
#import "SyncManagerViewController.h"

#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "UnderRightViewController.h"

#import "SBShoppingCart+Extensions.h"
#import "SBItem+Extensions.h"

#import "SBVariant+Extensions.h"

#import "SBCatalog+Extensions.h"

#import "CatalogsAndCartsViewController.h"
#import "SBCustomer+Extensions.h"

#import "SBDocument+Extensions.h"

#import "SBVariantMatrixViewController.h"

#import "SBVariantMatrix.h"
#import "SBAssortment+Extensions.h"
#import "SBVariant+Extensions.h"
#import "SBStock+Extensions.h"

#include <stdlib.h>

#import "SBAddress+Extensions.h"
#import "EditableDetailViewController.h"

#import "SAGSearchManager.h"

@interface LoginManagerViewController (private)

- (void)saveSettingsToDB;

@end

@implementation LoginManagerViewController
{
    DragDropCrane *crane;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _lblVersion.text = [SAGHelper getAppVersion];
    
    [[SAGLoginManager sharedManger] setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:notificationMediaDownloadStateChanged object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]])
    {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }

    [self refresh];
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)revealUnderRight:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TriggerAction

- (IBAction)changeState:(UIButton *)sender
{
    [self changeLoginState];
}

- (IBAction)changePage:(UIPageControl *)sender
{
    [[SAGLoginManager sharedManger] setCurrentDatabase:sender.currentPage];
    [self refresh];
}

- (IBAction)deleteUser:(UIButton *)sender
{
    PSPDFActionSheet *alert = [[PSPDFActionSheet alloc] initWithTitle:nil];
    
    [alert addButtonWithTitle:NSLocalizedString(@"Database", @"Drop Database") block:^{
        
        [[SAGLoginManager sharedManger] dropDatabaseWithImages:NO];
        [self refresh];
    }];
    
    [alert addButtonWithTitle:NSLocalizedString(@"Database and Pictures", @"Drop Database") block:^{
        
        [[SAGLoginManager sharedManger] dropDatabaseWithImages:YES];
        [self refresh];
    }];

    [alert addButtonWithTitle:NSLocalizedString(@"Pictures only", @"Drop Pictures") block:^{
        
        NSString *storePath = [SBMedia userMediaDirectory];
        
        NSError *error;
        
        [[NSFileManager defaultManager] removeItemAtPath:storePath error:&error];
        
        if (error)
        {
            DDLogError(@"## UserMediaDirectory remove error: %@", error.localizedDescription);
        }
        
        [SBMedia checkMediaFilesToBeDeleted];
    }];
    
    [alert setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") block:nil];
    
    [alert showWithSender:sender fallbackView:self.view animated:YES];
}

- (IBAction)syncronizeData:(UIButton *)sender
{
    [[SAGSyncManager sharedClient] synchronizeAll];
}

- (IBAction)toggelMediaDownload:(UIButton *)sender
{
    [[SAGSyncManager sharedClient] setIsMediaDownloadPaused:![[SAGSyncManager sharedClient] isMediaDownloadPaused]];
    [self refresh];
}

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender
{
    if (_pageControl.currentPage + 1 < _pageControl.numberOfPages)
    {
        [[SAGLoginManager sharedManger] setCurrentDatabase:_pageControl.currentPage + 1];
        [self refresh];
    }
}

- (IBAction)swipeRight:(UISwipeGestureRecognizer *)sender
{
    if (_pageControl.currentPage - 1 >= 0)
    {
        [[SAGLoginManager sharedManger] setCurrentDatabase:_pageControl.currentPage - 1];
        [self refresh];
    }
}

#pragma mark - Andy

- (IBAction)doAndy:(id)sender
{
    //[SBFilter testFilterWithEntity:@"SBVariant" numberOfTests:2];
    //[SBFilter testFilterWithEntity:@"SBAddress" numberOfTests:2];
    
    [[SAGSearchManager sharedClient] setObjectsToSearch:[SBVariant MR_findAll]];
    [[SAGSearchManager sharedClient] setSearchString:@"W"];
}


#pragma mark - Julian

- (IBAction)doJulian:(id)sender
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^(void)
    {
//        [self createDemoVariants];
       
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [self doSomeWork:sender];
        });
    });

    return;
}

- (void)doSomeWork:(id)obj
{
//    NSArray *dropViews = [NSArray arrayWithObjects:self.txtUsername, self.txtPassword, nil];
//    NSArray *dragViews = [NSArray arrayWithObject:obj];
//
//    crane = [[SAGDragDropCrane alloc] initWithViewsToDropOn:dropViews andDraggableViews:dragViews];
//
//    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:crane action:@selector(dragging:)];
//    
//    [self.view addGestureRecognizer:recognizer];
//
//    return;

//    SBShoppingCart *cart = [SBShoppingCart createNewCartWithName:@"1stCart"];
//
//    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
//
//    SBItem *item = [SBItem getItemWithItemNumber:@"1-1-22469-20"];
//
//    SBVariantMatrix *matrix = [[SBVariantMatrix alloc] initWithItem:item andCart:cart];
//
//    [matrix showUI];
//    
//    return;
}

#pragma mark - Frank

- (IBAction)doFrank:(id)sender
{
	SBAddress *address = [SBAddress MR_findFirstByAttribute:@"addressType" withValue:@(SAGAddressTypePrimaryAddress)];
	EditableDetailViewController *controller = [EditableDetailViewController editableDetailViewController];
	
	controller.editingMode = EditableDetailViewControllerEditingModeExisting;
	controller.entity = address;
	
	[controller presentInViewController:self];
}

#pragma mark - Textfield Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:_txtPassword])
    {
        if (textField.text.length > 3)
        {
            _btnChangeState.hidden = NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:_txtUsername])
    {
        _imgCheckEmail.hidden = YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField isEqual:_txtUsername])
    {
        if ([_txtUsername.text isValidEmail])
        {
            _imgCheckEmail.hidden = NO;
        }
        else
        {
            _imgCheckEmail.hidden = YES;
        }
    }
    else if ([textField isEqual:_txtStartCode])
    {
        [self tryStartcode];
        [_txtUsername becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_txtPassword])
    {
        [self changeLoginState];
    }
    else if ([textField isEqual:_txtUsername])
    {
        [_txtPassword becomeFirstResponder];
    }
    else if ([textField isEqual:_txtStartCode])
    {
        [_txtUsername becomeFirstResponder];
    }
    
    return YES;
}

- (void)tryStartcode
{
    [[SAGLoginManager sharedManger] retriveLoginInformationForStartCode:_txtStartCode.text];
}

- (void)loginManagerStartcodeAnswerRecived:(NSDictionary *)answer
{
    if (answer)
    {
        _txtUsername.text = [answer valueForKey:@"username"];
        _txtPassword.text = [answer valueForKey:@"password"];
        _txtStartCode.text = [answer valueForKey:@"startcode"];
        
        if (_txtUsername.text.length > 0)
        {
            if ([_txtPassword.text length] > 0)
            {
                [_txtStartCode resignFirstResponder];
                [self changeLoginState];
            }
            else
            {
                [_txtUsername resignFirstResponder];
                [_txtPassword becomeFirstResponder];
            }
        }
    }
    else
    {
        [SAGHelper playSound:@"error" withExtension:@"wav"];
        _txtStartCode.text = @"";
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([textField isEqual:_txtUsername])
    {
        _btnChangeState.hidden = YES;
        _txtPassword.text = @"";
    }
    
    return YES;
}

#pragma mark - LoginManager Delegate

- (NSString *)loginManagerGetPassword
{
    return _txtPassword.text;
}

- (NSString *)loginManagerGetUsername
{
    return _txtUsername.text;
}

- (void)loginManagerResetPassword
{
    _txtPassword.text = @"";
    _btnChangeState.hidden = YES;
}

- (void)loginManagerTaskCompletedWithMessage:(NSString *)message
{
    [_activityIndicator stopAnimating];
    
    if (message)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    [self refresh];
}

- (void)loginManagerWrongPassword
{
    [SAGHelper playSound:@"error" withExtension:@"wav"];
    [self shakeAnimation:_txtPassword];
    [self refresh];
}

- (void)loginManagerInitiateSyncronization
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    SyncManagerViewController *syncView = [storyboard instantiateViewControllerWithIdentifier:@"SyncManagerUI"];
    syncView.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:syncView animated:YES completion:^{
        DDLogInfo(@"Syncronization started!");
    }];
}

- (void)loginManagerRenewLastSync
{
    _lblLastSync.text = [[SAGLoginManager sharedManger] lastUpdate];
}

#pragma mark - internal stuff

- (void)changeLoginState
{
    [_txtPassword resignFirstResponder];
    
    _btnChangeState.hidden = YES;
    _txtPassword.enabled = NO;
    _txtUsername.enabled = NO;
    _pageControl.enabled = NO;
    
    [_activityIndicator startAnimating];
    
    if ([[SAGLoginManager sharedManger] isDatabaseOpen])
    {
        [[SAGLoginManager sharedManger] logout];
    }
    else
    {
        [[SAGLoginManager sharedManger] login];
    }
}

- (void)refresh
{
    [_activityIndicator stopAnimating];
    _txtStartCode.hidden = YES;
    _pageControl.enabled = YES;
    _btnDelete.hidden = YES;
    _btnMenue.enabled = NO;
    _btnSyncronize.hidden = YES;
    
    //Wenn Datenbank geöffnet offen dann ist ein Benutzer angemeldet!
    BOOL userLoggedIn = [[SAGLoginManager sharedManger] isDatabaseOpen];
    
    _txtUsername.text = [[SAGLoginManager sharedManger] username];
    _lblLastSync.text = [[SAGLoginManager sharedManger] lastUpdate];
    
    _pageControl.numberOfPages = [[SAGLoginManager sharedManger] numberOfDatabases];
    _pageControl.currentPage = [[SAGLoginManager sharedManger] currentDatabase];
    
    _txtPassword.enabled = !userLoggedIn;
    _txtUsername.enabled = !userLoggedIn;
    
    _lblLastSync.hidden = !userLoggedIn;
    
    for (UISwipeGestureRecognizer *rec in _swipeRecognizers)
    {
        rec.enabled = !userLoggedIn;
    }
    
    _pageControl.hidden = userLoggedIn;
    
    if (_txtPassword.text.length > 4 || userLoggedIn)
    {
        _btnChangeState.hidden = NO;
    }
    
    _btnMediaDownload.hidden = ![[SAGSyncManager sharedClient] isMediaDownloadActive];
    
    if (_btnMediaDownload.hidden == NO)
    {
        if ([[SAGSyncManager sharedClient] isMediaDownloadPaused])
        {
            [_btnMediaDownload setImage:[UIImage imageNamed:@"button-play.png"] forState:UIControlStateNormal];
        }
        else
        {
            [_btnMediaDownload setImage:[UIImage imageNamed:@"button-pause.png"] forState:UIControlStateNormal];
        }
    }

#if defined (CONFIGURATION_Debug)
    [self showDevolperButtons:!userLoggedIn];
#endif
    
    if (userLoggedIn)
    {
        [_btnChangeState setImage:[UIImage imageNamed:@"lock.png"] forState:UIControlStateNormal];
        _btnMenue.enabled = YES;
        _btnSyncronize.hidden = NO;
        
        _txtPassword.text = @"########";
        
        [self.view addGestureRecognizer:self.slidingViewController.panGesture]; //Den Menü-Controller aktivieren
    }
    else
    {
        _lblLastSync.text = [[SAGLoginManager sharedManger] serverID]; //Die ServerID anzeigen!
        _lblLastSync.hidden = [_lblLastSync.text isEqualToString:kDefaultServerID];
        
        [_btnChangeState setImage:[UIImage imageNamed:@"lock-unlock.png"] forState:UIControlStateNormal];
        
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture]; //Den Menü-Controller deaktivieren
    }
    
    if ([_txtUsername.text isValidEmail])
    {
        _imgCheckEmail.hidden = NO;
    }
    else
    {
        _imgCheckEmail.hidden = YES;
    }
    
    if (_pageControl.numberOfPages == 0 || _pageControl.currentPage == _pageControl.numberOfPages - 1)
    {
        _txtStartCode.hidden = NO;
        _txtStartCode.text = @"";
    }
    else
    {
        _txtUsername.enabled = NO;
        
        if (!userLoggedIn)
        {
            _btnDelete.hidden = NO;
        }
    }
    
    //Felder einfärben, je nachdem ob sie editierbar sind oder nicht...
    
    if (_txtPassword.enabled)
    {
        _txtPassword.textColor = [UIColor blackColor];
    }
    else
    {
        _txtPassword.textColor = [UIColor grayColor];
    }
    
    if (_txtUsername.enabled)
    {
        _txtUsername.textColor = [UIColor blackColor];
    }
    else
    {
        _txtUsername.textColor = [UIColor grayColor];
    }
}

-(void)shakeAnimation:(UIView*) view
{
    const int reset = 5;
    const int maxShakes = 6;
    
    //pass these as variables instead of statics or class variables if shaking two controls simultaneously
    static int shakes = 2;
    static int translate = reset;
    
    [UIView animateWithDuration:0.09-(shakes*.01) // reduce duration every shake from .09 to .04
                          delay:0.001f//edge wait delay
                        options:(enum UIViewAnimationOptions) UIViewAnimationCurveLinear
                     animations:^{view.transform = CGAffineTransformMakeTranslation(translate, 0);}
                     completion:^(BOOL finished){
                         if(shakes < maxShakes){
                             shakes++;
                             
                             //throttle down movement
                             if (translate>0)
                                 translate--;
                             
                             //change direction
                             translate*=-1;
                             [self shakeAnimation:view];
                         } else {
                             view.transform = CGAffineTransformIdentity;
                             shakes = 0;//ready for next time
                             translate = reset;//ready for next time
                             return;
                         }
                     }];
}


- (void)showDevolperButtons:(BOOL)show
{
    for (UIButton *button in _developerButtons)
    {
        button.hidden = show;
    }
}

@end
