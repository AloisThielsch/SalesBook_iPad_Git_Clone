//
//  SBDocumentType.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SBDocumentType : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * denotationValue;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSNumber * documentTypeID;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;

@end
