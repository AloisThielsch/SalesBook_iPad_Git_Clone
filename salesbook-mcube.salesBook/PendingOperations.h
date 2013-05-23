//
//  PendingOperations.h
//  SalesBook
//
//  Created by Andreas Kucher on 11.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingOperations : NSObject

@property (nonatomic, strong) NSMutableDictionary *renderInProgress;
@property (nonatomic, strong) NSOperationQueue *renderQueue;

@end
