//
//  SAGSearchManager.h
//  SalesBook
//
//  Created by Andreas Kucher on 21.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SAGSearchManagerDelegate <NSObject>

- (void)suggestionsUpdated:(NSArray *)suggestions;

@end

@interface SAGSearchManager : NSObject

@property (nonatomic, weak) id <SAGSearchManagerDelegate> delegate;

@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, weak) NSArray *objectsToSearch;

+ (SAGSearchManager *)sharedClient;

@end
