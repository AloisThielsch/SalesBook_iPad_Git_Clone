//
//  SBAddress+MKAnnotation.m
//  SalesBook
//
//  Created by Frank Wittmann on 18.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBAddress+MKAnnotation.h"

#import "SBAddress+Extensions.h"
#import "SBCustomer+Extensions.h"

@implementation SBAddress(MKAnnotation)

- (CLLocationCoordinate2D)coordinate
{
	return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)title
{
	return self.name1 ? self.name1 : self.customerNumber;
}

- (NSString *)subtitle
{
	return [NSString stringWithFormat:@"%@, %@", self.street, [self zipCity]];
}

- (CLLocation *)location
{
	return [[CLLocation alloc] initWithLatitude:self.latitudeDegress longitude:self.longitudeDegress];
}

- (CLLocationDegrees)latitudeDegress
{
	return (CLLocationDegrees)[self.latitude doubleValue];
}

- (CLLocationDegrees)longitudeDegress
{
	return (CLLocationDegrees)[self.longitude doubleValue];
}

@end
