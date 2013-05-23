//
//  ContainerViewControllerProxy.m
//  SalesBook
//
//  Created by Frank Wittmann on 17.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "ContainerViewControllerProxy.h"

#import "CustomerSelectorTableViewController.h"
#import "CustomerSelectorMapViewController.h"

@interface ContainerViewControllerProxy()
@property (nonatomic, strong) NSString *currentSegueIdentifier;
@end

@implementation ContainerViewControllerProxy

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.currentSegueIdentifier = @"embedList";
	[self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"embedList"]) {
		if (self.childViewControllers.count > 0) {
			[self swapFromViewController:[self.childViewControllers objectAtIndex:0]
						toViewController:segue.destinationViewController];
		} else {
			[self addChildViewController:segue.destinationViewController];
			((UIViewController *)segue.destinationViewController).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
			[self.view addSubview:((UIViewController *)segue.destinationViewController).view];
			[segue.destinationViewController didMoveToParentViewController:self];
		}
	} else if ([segue.identifier isEqualToString:@"embedMap"]) {
		[self swapFromViewController:[self.childViewControllers objectAtIndex:0]
					toViewController:segue.destinationViewController];
	}
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
	toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	
	[fromViewController willMoveToParentViewController:nil];
	[self addChildViewController:toViewController];
	[self transitionFromViewController:fromViewController
					  toViewController:toViewController
							  duration:0.25
							   options:UIViewAnimationOptionTransitionCrossDissolve
							animations:nil
							completion:^(BOOL finished) {
								[fromViewController removeFromParentViewController];
								[toViewController didMoveToParentViewController:self];
							}];
}

- (void)switchToViewControllerWithSegueIdentifier:(NSString *)segueIdentifier {
	self.currentSegueIdentifier = segueIdentifier;
	[self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	if ([self.childViewControllers count] > 0) {
		((UIViewController *)[self.childViewControllers objectAtIndex:0]).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	}
}

@end
