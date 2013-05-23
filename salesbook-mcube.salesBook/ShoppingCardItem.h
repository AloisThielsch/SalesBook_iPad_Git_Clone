//
//  ShoppingCardItem.h
//  SalesBook
//
//  Created by Matthias Spohn on 29.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShoppingCardItem : NSObject

@property (nonatomic) int pos;
@property (nonatomic) NSString * number;
@property (nonatomic) NSString * color;
@property (nonatomic) NSString * date;
@property (nonatomic) NSString * due;
@property (nonatomic) NSString * imagepath;
@property (nonatomic) NSString * totalpairs;
@property (nonatomic) NSString * preis1;
@property (nonatomic) NSString * preis2;
@property (nonatomic) NSString * sortiment;

@property (nonatomic) NSString * quantity;
@property (nonatomic) NSString * size;
@property (nonatomic) NSArray * quantites;
@property (nonatomic) NSArray * sizes;

@property (nonatomic) NSString * ME;
@property (nonatomic) NSString * Farbe;
@property (nonatomic) NSString * Markenbezeichnung;
@property (nonatomic) NSString * Produktlinie;
@property (nonatomic) NSString * Obermaterial;

@property (nonatomic) NSString * Artikeltext1;
@property (nonatomic) NSString * Artikeltext2;
@property (nonatomic) NSString * Projektname;

@end