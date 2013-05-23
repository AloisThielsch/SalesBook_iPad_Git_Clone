//
//  HorizontalTabController.m
//  SalesBook
//
//  Created by Frank Wittmann on 17.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "HorizontalTabController.h"

@interface HorizontalTabController()
@property (nonatomic, strong) NSMutableArray *tabs;
@end

@implementation HorizontalTabController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews
{
	for (UIView *subview in self.view.subviews) {
		[subview removeFromSuperview];
	}

	CGFloat buttonWith = (self.view.frame.size.width - 10 * ([_tabs count] + 1)) / [_tabs count];
	CGFloat buttonHeight = (self.view.frame.size.height - 10);
	CGFloat offsetX = 10;
	NSInteger tag = 0;

	for (NSDictionary *tabInfo in _tabs) {
		UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
		tabButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
		tabButton.titleLabel.shadowColor = [UIColor blackColor];
		tabButton.titleLabel.shadowOffset = CGSizeMake(-1, 1);
		[tabButton setTitle:tabInfo[@"title"] forState:UIControlStateNormal];
		[tabButton setBackgroundImage:[[UIImage imageNamed:@"tab_inactive.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 0, 20) resizingMode:UIImageResizingModeStretch]
							 forState:UIControlStateNormal];
		[tabButton setBackgroundImage:[[UIImage imageNamed:@"tab_active.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 0, 20) resizingMode:UIImageResizingModeStretch]
							 forState:UIControlStateSelected];
		
		tabButton.frame = CGRectMake(offsetX, 10, buttonWith, buttonHeight);
		offsetX += buttonWith + 10;
		
		[tabButton addTarget:self action:@selector(tabSelected:) forControlEvents:UIControlEventTouchUpInside];
		tabButton.tag = tag++;
		
		[self.view addSubview:tabButton];
	}
	
	((UIButton *)[self.view.subviews objectAtIndex:0]).selected = YES;
}

- (void)addTabWithTitle:(NSString *)title forSegueIdentifier:(NSString *)segueIdentifier
{
	if (!_tabs) {
		_tabs = [NSMutableArray array];
	}
	
	[_tabs addObject:@{ @"title":title, @"segueIdentifier":segueIdentifier }];
}

- (void)tabSelected:(UIButton *)sender
{
	[self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		((UIButton *)obj).selected = NO;
	}];
	sender.selected = YES;
	
	NSDictionary *tabInfo = [_tabs objectAtIndex:sender.tag];
	if (tabInfo) {
		if (self.horizontalTabControllerDelegate &&
			[self.horizontalTabControllerDelegate respondsToSelector:@selector(horizontalTabController:didSelectTabWithTitle:segueIdentifier:)]) {
			[self.horizontalTabControllerDelegate horizontalTabController:self
													didSelectTabWithTitle:tabInfo[@"title"]
														  segueIdentifier:tabInfo[@"segueIdentifier"]];
		}
	}
}

@end
