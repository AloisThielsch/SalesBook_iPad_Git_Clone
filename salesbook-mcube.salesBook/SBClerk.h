//
//  SBClerk.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAddress, SBLanguage;

@interface SBClerk : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSString * clerkDenotaion;
@property (nonatomic, retain) NSString * clerkNumber;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * defaultLanguage;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSString * mailAddress;
@property (nonatomic, retain) NSNumber * maxNumDevices;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) SBAddress *address;
@property (nonatomic, retain) NSSet *languages;
@end

@interface SBClerk (CoreDataGeneratedAccessors)

- (void)addLanguagesObject:(SBLanguage *)value;
- (void)removeLanguagesObject:(SBLanguage *)value;
- (void)addLanguages:(NSSet *)values;
- (void)removeLanguages:(NSSet *)values;

@end
