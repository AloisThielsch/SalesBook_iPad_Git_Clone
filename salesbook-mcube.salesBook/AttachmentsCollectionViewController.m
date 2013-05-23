//
//  AttachmentsCollectionViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 30.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "AttachmentsCollectionViewController.h"

#import "AttachmentCell.h"
#import "CommonCollectionHeaderView.h"

#import "SBMedia+Extensions.h"

@interface AttachmentsCollectionViewController()
@end

@implementation AttachmentsCollectionViewController

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.attachmentArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	AttachmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttachmentCell" forIndexPath:indexPath];
	
	SBMedia *attachment = self.attachmentArray[indexPath.row];

	cell.labelFilename.text = [attachment fullFilename];
	cell.imageStatus.image = attachment.isDownloaded.boolValue ? nil : [UIImage imageNamed:@"exclamation-circle-frame.png"];
	
	if ([self mediaIsImage:attachment]) {
		cell.imagePreview.image = [attachment getImage];
	}
	
	return cell;
}

- (BOOL)mediaIsImage:(SBMedia *)media
{
	return (media.mediaType.integerValue == SAGMediaTypeSmall || media.mediaType.integerValue == SAGMediaTypeMedium || media.mediaType.integerValue == SAGMediaTypeLarge);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	CommonCollectionHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CommonHeaderView" forIndexPath:indexPath];
	
	view.labelHeader.text = NSLocalizedString(@"Attachments", @"Attachments");
	
	return view;
}

@end
