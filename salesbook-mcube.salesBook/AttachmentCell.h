//
//  AttachmentCell.h
//  SalesBook
//
//  Created by Frank Wittmann on 30.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommonCollectionCell.h"

@interface AttachmentCell : CommonCollectionCell

@property (weak, nonatomic) IBOutlet UILabel *labelFilename;
@property (weak, nonatomic) IBOutlet UIImageView *imageStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;

@end
