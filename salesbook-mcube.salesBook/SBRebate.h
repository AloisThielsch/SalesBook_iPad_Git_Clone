//
//  SBRebate.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBDocument, SBDocumentPosition;

@interface SBRebate : NSManagedObject

@property (nonatomic, retain) SBDocument *document;
@property (nonatomic, retain) SBDocumentPosition *documentPosition;

@end
