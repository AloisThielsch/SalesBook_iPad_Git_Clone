//
//  CardWithImageView.h
//  SalesBook
//
//  Created by Julian Knab on 21.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmallCardCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *colorsView;
@property (strong, nonatomic) IBOutlet UIImageView *lightView;

@property (strong, nonatomic) IBOutlet UILabel *label0;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;
@property (strong, nonatomic) IBOutlet UILabel *label3;

@end