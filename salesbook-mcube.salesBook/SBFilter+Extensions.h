//
//  SBFilter+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 25.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBFilter.h"

@class SBFilterLevel;

@interface SBFilter (Extensions)

+ (SBFilter *)filterWithTargetEntity:(NSString *)targetEntity andName:(NSString *)name;

- (bool)setObjectToFilter:(NSManagedObject *)managedObject;
- (bool)setObjectsToFilter:(NSSet *)managedObjects; //Führt automatisch einen clear Cache aus, dann wird der Filter level für level ausgeführt.

- (bool)addFilterLevelWithValue:(id)value andKey:(NSString *)key; //Fügt dem Filter ein neues Level hinzu.
- (bool)addFilterLevelWithValues:(NSArray *)values andKey:(NSString *)key;

- (void)removeLastFilterLevel; //Entfernt das letzte Filterlevel
- (void)removeFilterAtLevel:(int)level;

- (void)removeFilter; //Filter löschen

- (void)refreshFilter; //Löscht den Cache und führt den Filter erneut aus
- (void)saveFilter; //Den Filter speichern!

- (void)clearCache;

- (NSArray *)getResult; //Liefert das Ergabnis des Filters zurück
- (NSArray *)getResultWithEntity:(NSString *)entityOrNil; //Liefert das Ergebnis des Filters als related Entity zurück

///Anzeige

+ (NSArray *)availableFiltersForEntity:(NSString *)targetEntity; //Liefert alle gespeicherten Filter zurück.

- (NSArray *)availableKeys; //Liefert alle mit isFilterable markierten Customfields aus.

- (NSArray *)distinctValuesForKey:(NSString *)key; //Liefert die Ergebnisse eines einzelnen Keys auf Basis des aktuellen Filters zurück

- (SBFilterLevel *)filterlevelforKey:(NSString *)key;

- (void)moveFilterLevelAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)destination;

//Test

+ (BOOL)testFilterWithEntity:(NSString *)entityToFetch numberOfTests:(int)numberOfTests;

@end
