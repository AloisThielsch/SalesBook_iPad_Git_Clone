//
//  SBContact.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAddress, SBAttribute, SBCustomer;

@interface SBContact : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSString * annotation;
@property (nonatomic, retain) NSString * contactNumber;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * customerNumber;
@property (nonatomic, retain) NSDate * dateOfBirth;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSString * mail;
@property (nonatomic, retain) NSString * name1;
@property (nonatomic, retain) NSString * name2;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * salutation;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSSet *adresses;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) SBCustomer *customer;
@end

@interface SBContact (CoreDataGeneratedAccessors)

- (void)addAdressesObject:(SBAddress *)value;
- (void)removeAdressesObject:(SBAddress *)value;
- (void)addAdresses:(NSSet *)values;
- (void)removeAdresses:(NSSet *)values;

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

@end
