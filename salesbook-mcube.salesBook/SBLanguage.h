//
//  SBLanguage.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBClerk;

@interface SBLanguage : NSManagedObject

@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSString * languageDenotation;
@property (nonatomic, retain) NSString * languageNumber;
@property (nonatomic, retain) SBClerk *clerk;

@end
