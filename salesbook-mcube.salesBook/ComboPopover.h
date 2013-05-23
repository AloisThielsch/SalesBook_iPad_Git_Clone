//
//  ComboPopover.h
//  SalesBook
//
//  Created by Frank Wittmann on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ComboPopover;

@protocol ComboPopoverDelegate<NSObject>
- (void)didDismissComboPopover:(ComboPopover *)comboPopover;
- (void)comboPopover:(ComboPopover *)comboPopover didSelectObject:(id)object;
@end

@interface ComboPopover : NSObject

@property (nonatomic, strong) NSArray *itemArray;
@property (nonatomic, strong) NSMutableArray *selectedItemArray;
@property (nonatomic) BOOL multipleSelection;
@property (nonatomic) BOOL searchEnabled;
@property (nonatomic) BOOL embedInNavigationController;
@property (nonatomic, readonly) UINavigationItem *navigationItem;

- (id)initWithItemArray:(NSArray *)itemArray labelKeyPath:(NSString *)labelKeyPath valueKeyPath:(NSString *)valueKeyPath delegate:(id<ComboPopoverDelegate>)delegate;

- (void)toggleFromRect:(CGRect)frame inView:(UIView *)view;
- (void)toggleFromRect:(CGRect)frame inView:(UIView *)view direction:(UIPopoverArrowDirection)direction;
- (void)dismiss;

@end
