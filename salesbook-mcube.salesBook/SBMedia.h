//
//  SBMedia.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAttribute, SBCustomer, SBVariant;

@interface SBMedia : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSString * colorNumber;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * customerNumber;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSString * downloadPriority;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * fileNameExtension;
@property (nonatomic, retain) NSString * hashCode;
@property (nonatomic, retain) NSNumber * isDownloaded;
@property (nonatomic, retain) NSNumber * loadIfMobile;
@property (nonatomic, retain) NSNumber * mediaType;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * variantNumber;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) SBCustomer *customer;
@property (nonatomic, retain) NSSet *variants;
@end

@interface SBMedia (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addVariantsObject:(SBVariant *)value;
- (void)removeVariantsObject:(SBVariant *)value;
- (void)addVariants:(NSSet *)values;
- (void)removeVariants:(NSSet *)values;

@end
