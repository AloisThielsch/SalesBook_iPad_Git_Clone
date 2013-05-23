//
//  PendingOperations.m
//  SalesBook
//
//  Created by Andreas Kucher on 11.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "PendingOperations.h"
#import "ImageRenderer.h"

@implementation PendingOperations

@synthesize renderQueue = _renderQueue;
@synthesize renderInProgress = _renderInProgress;

- (NSMutableDictionary *)renderInProgress
{
    if (!_renderInProgress)
    {
        _renderInProgress = [NSMutableDictionary new];
    }
    
    return _renderInProgress;
}

- (NSOperationQueue *)renderQueue
{
    if (!_renderQueue)
    {
        _renderQueue = [[NSOperationQueue alloc] init];
        _renderQueue.name = @"Image Render Queue";
        _renderQueue.maxConcurrentOperationCount = 1;
    }
    
    return _renderQueue;
}

@end
