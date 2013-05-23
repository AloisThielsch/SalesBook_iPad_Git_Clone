//
//  SBWebserviceInfo.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SBWebserviceInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * recordID;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * webservice;

@end
