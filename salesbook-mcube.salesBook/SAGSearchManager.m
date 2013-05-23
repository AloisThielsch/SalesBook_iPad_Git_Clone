//
//  SAGSearchManager.m
//  SalesBook
//
//  Created by Andreas Kucher on 21.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SAGSearchManager.h"

#import "SBCustomField+Extensions.h"
#import "SBFilter+Extensions.h"

#import "SAGLoginManager.h"

@interface SAGSearchManager ()

@property (nonatomic, strong) NSMutableArray *searchIndex;
@property (nonatomic, strong) NSString *currentEntity;
@property (nonatomic, strong) NSMutableArray *suggestions;

@end

@implementation SAGSearchManager

+ (SAGSearchManager *)sharedClient
{
    static SAGSearchManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SAGSearchManager alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCache) name:notificationLogoutSuccessful object:nil];
    
    return self;
}

- (void)setObjectsToSearch:(NSArray *)objectsToSearch
{
    if ([objectsToSearch isEqualToArray:_objectsToSearch]) return; //Wenn die Objekte sich nicht verändern, muss nix gemacht werden!
    
    _objectsToSearch = objectsToSearch;
    
    NSManagedObject *someObject;
    
    if (objectsToSearch.count > 0)
    {
        someObject = (NSManagedObject *)objectsToSearch[0];
    }
    
    [self buildSearchIndex:someObject.entity.name]; //Welche entity wird durchsucht!
}

- (void)buildSearchIndex:(NSString *)currentEntity
{
    if ([_currentEntity isEqualToString:currentEntity]) return; //Wird die Entity nicht verändert muss kein neuer Suchindex erzeug werden.
    
    _currentEntity = currentEntity;
    
    [self createSearchIndexes];

}

- (void)createSearchIndexes
{
    NSArray *searchableKeys = [SBCustomField getSearchableKeysForEntity:self.currentEntity];
    
    if (searchableKeys.count == 0)
    {
        DDLogWarn(@"%@", NSLocalizedString(@"SearchIndex -> no additional Searchfields defined!", @""));
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        SBFilter *tempFilter = [SBFilter filterWithTargetEntity:self.currentEntity andName:@"Created by SearchIndex"];
        [tempFilter setObjectsToFilter:[NSSet setWithArray:_objectsToSearch]];
        
        NSMutableArray *searchIndexes = [NSMutableArray new];
        
        for (NSDictionary *info in searchableKeys)
        {
            if (![[SAGLoginManager sharedManger] isDatabaseOpen]) continue;
                
            NSArray *values = [tempFilter distinctValuesForKey:[info valueForKey:@"key"]];
            
            if (values.count == 0)
            {
                [searchIndexes addObject:@{@"head": info, @"values": [NSArray array]}];
            }
            else
            {
                [searchIndexes addObject:@{@"head": info, @"values": values}];
            }
        }
        
        if ([[SAGLoginManager sharedManger] isDatabaseOpen]) [tempFilter removeFilter];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([[SAGLoginManager sharedManger] isDatabaseOpen])
            {
                _searchIndex = searchIndexes;
                
                DDLogInfo(@"%@", NSLocalizedString(@"SearchIndex created!", @""));
            }
            else
            {
                [self clearCache];
            }
        });
    });
}

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;
    
    [self updateSuggestions];
}

- (void)clearCache
{
    [_searchIndex removeAllObjects];
    _currentEntity = nil;
}

- (void)updateSuggestions
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSMutableArray *filteredKeys = [NSMutableArray new];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[cd] %@", @"value", _searchString];
        
        for (NSDictionary *info in _searchIndex)
        {
            NSArray *filteredValues = [[info valueForKey:@"values"] filteredArrayUsingPredicate:predicate];
            
            if (filteredValues.count > 0) [filteredKeys addObject:@{@"info": [info valueForKey:@"head"], @"values": filteredValues}];
        }
        
        _suggestions = filteredKeys;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_delegate suggestionsUpdated:_suggestions];
        });
    });
}

@end
