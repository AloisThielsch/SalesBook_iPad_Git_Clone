//
//  DocumentsViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 30.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "DocumentsViewController.h"
#import "ECSlidingViewController.h"
#import "DocumentsCollectionViewController.h"

#import "SBDocument+Extensions.h"
#import "SBCustomer+Extensions.h"

#import "SAGMenuController.h"

@interface DocumentsViewController()
@end

@implementation DocumentsViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"embedDocumentsCollectionView"]) {
		NSArray *documents = [SBDocument getDocumentsOfDocumentType:[self.documentType integerValue] withCustomer:[SAGMenuController defaultController].customer];
		((DocumentsCollectionViewController *)segue.destinationViewController).documentArray = documents;
	}
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

@end
