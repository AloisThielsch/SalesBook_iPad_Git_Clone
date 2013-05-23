//
//  AttachmentsViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 30.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "AttachmentsViewController.h"
#import "ECSlidingViewController.h"
#import "AttachmentsCollectionViewController.h"

#import "SAGMenuController.h"

#import "SBCustomer+Extensions.h"

@interface AttachmentsViewController()
@end

@implementation AttachmentsViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"embedAttachmentsCollectionView"]) {
		NSArray *attachments = [[SAGMenuController defaultController].customer.mediaFiles allObjects];
		((AttachmentsCollectionViewController *)segue.destinationViewController).attachmentArray = attachments;
	}
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

@end
