//
//  SBAddress+MKAnnotation.h
//  SalesBook
//
//  Created by Frank Wittmann on 18.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBAddress.h"

#import <MapKit/MapKit.h>

@interface SBAddress(MKAnnotation)<MKAnnotation>

@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) CLLocationDegrees latitudeDegress;
@property (nonatomic, readonly) CLLocationDegrees longitudeDegress;

@end
