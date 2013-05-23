//
//  PSPDFActionSheet.m
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "PSPDFActionSheet.h"
#import <objc/runtime.h>

@interface PSPDFActionSheet() <UIActionSheetDelegate> {
    id<UIActionSheetDelegate> _realDelegate;
    NSMutableArray *_blocks;
    void (^_destroyBlock)(PSPDFActionSheet *sheet, NSInteger buttonIndex);
}
@end

@implementation PSPDFActionSheet

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithTitle:(NSString *)title {
    if ((self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil])) {

        // Create the blocks storage for handling all button actions
        _blocks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)setDelegate:(id<UIActionSheetDelegate>)delegate {
    if (delegate == nil) {
        [super setDelegate:nil];
        _realDelegate = nil;
    }else {
        [super setDelegate:self];
        if (delegate != self) {
            _realDelegate = delegate;
        }
    }
}

- (void)setDestructiveButtonWithTitle:(NSString *) title extendedBlock:(void (^)(PSPDFActionSheet *sheet, NSInteger buttonIndex))block {
    assert([title length] > 0 && "sheet destructive button title must not be empty");

    [self addButtonWithTitle:title extendedBlock:block];
    self.destructiveButtonIndex = (self.numberOfButtons - 1);
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block {
    block = [block copy];
    [self setDestructiveButtonWithTitle:title extendedBlock:^(PSPDFActionSheet *alert, NSInteger buttonIndex) {
        if (block) block();
    }];
}

- (void)setCancelButtonWithTitle:(NSString *) title extendedBlock:(void (^)(PSPDFActionSheet *sheet, NSInteger buttonIndex))block {
    assert([title length] > 0 && "sheet cancel button title must not be empty");

    [self addButtonWithTitle:title extendedBlock:block];
    self.cancelButtonIndex = (self.numberOfButtons - 1);
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block {
    block = [block copy];
    [self setCancelButtonWithTitle:title extendedBlock:^(PSPDFActionSheet *sheet, NSInteger buttonIndex) {
        if (block) block();
    }];
}

- (void)addButtonWithTitle:(NSString *) title extendedBlock:(void (^)(PSPDFActionSheet *sheet, NSInteger buttonIndex))block {
    assert([title length] > 0 && "cannot add button with empty title");

    [_blocks addObject:block ? [block copy] : [NSNull null]];
    [self addButtonWithTitle:title];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block {
    block = [block copy];
    [self addButtonWithTitle:title extendedBlock:^(PSPDFActionSheet *alert, NSInteger buttonIndex) {
        if (block) block();
    }];
}

- (NSUInteger)buttonCount {
    return [_blocks count];
}

- (void)showWithSender:(id)sender fallbackView:(UIView *)view animated:(BOOL)animated {
    BOOL isIPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    if (isIPad && [sender isKindOfClass:[UIBarButtonItem class]]) {
        [self showFromBarButtonItem:sender animated:animated];
    }else if (isIPad && [sender isKindOfClass:[UIView class]]) {
        [self showFromRect:[sender bounds] inView:sender animated:animated];
    }else {
        [self showInView:view];
    }
}

- (void)destroy {
    [_blocks removeAllObjects];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIActionSheet

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    [self destroy];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Run the button's block
    if (buttonIndex >= 0 && buttonIndex < [_blocks count]) {
        id obj = _blocks[buttonIndex];
        if (![obj isEqual:[NSNull null]]) {
            ((void (^)())obj)(actionSheet, buttonIndex);
        }
    }

    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }

    // manually break potential retain cycles
    [_blocks removeAllObjects];
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate actionSheetCancel:actionSheet];
    }
}

// before animation and showing view
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate willPresentActionSheet:actionSheet];
    }
}

// after animation
- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate didPresentActionSheet:actionSheet];
    }
}

// before animation and hiding view
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
    }
}

// after animation
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
    }

    [self destroy];
    if (_destroyBlock) {
        _destroyBlock(self, buttonIndex);
    }
    self.delegate = nil;
}

@end
