//
//  CustomerSelectorMapViewController.m
//  SalesBook
//
//  Created by Julian Knab on 07.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CustomerSelectorMapViewController.h"

#import "SBCustomer+Extensions.h"

#import "SBAddress+Extensions.h"
#import "SBAddress+MKAnnotation.h"

#import "SAGObjectSelectionManager.h"

#import <MapKit/MapKit.h>

const CLLocationDistance kInitialDistance = 50000;
const NSInteger kMinimalItemCount = 10;
const CGFloat kDistanceScaleFactor = 2.0;
const CGFloat kRegionPaddingFactor = 1.2;

@interface CustomerSelectorMapViewController()<MKMapViewDelegate>
@property (nonatomic, strong) NSArray *addresses;
@property (weak, nonatomic) IBOutlet MKMapView *customerMapView;
@property (nonatomic, strong) CLLocation *initialLocation;
@property (nonatomic, strong) dispatch_queue_t annotationQueue;
@end

@implementation CustomerSelectorMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (dispatch_queue_t)annotationQueue
{
	if (!_annotationQueue) {
		_annotationQueue = dispatch_queue_create("annotationQueue", NULL);
	}

	return _annotationQueue;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}

	MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomerAnnotation"];
	annotationView.pinColor = MKPinAnnotationColorRed;
	annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	annotationView.canShowCallout = YES;
	annotationView.enabled = YES;
	
	return annotationView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	SBAddress *address = (SBAddress *)view.annotation;
	if (address) {
		[[SAGObjectSelectionManager sharedManager] broadcastSelectionOfEntity:@"SBCustomer" withObjectID:address.customer.objectID];
	}
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[self reloadAnnotationsInMapView:mapView];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	if (!_initialLocation) {
		self.initialLocation = userLocation.location;
		MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, kInitialDistance, kInitialDistance);
		[mapView setRegion:mapRegion animated:NO];
	}
}

-(void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	dispatch_suspend(self.annotationQueue);
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	dispatch_resume(self.annotationQueue);
}

#pragma mark - Helpers

- (void)reloadAnnotationsInMapView:(MKMapView *)mapView;
{
	MKMapRect mapRect = mapView.visibleMapRect;
	MKMapPoint neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), mapRect.origin.y);
	MKMapPoint swMapPoint = MKMapPointMake(mapRect.origin.x, MKMapRectGetMaxY(mapRect));
	MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(mapRect), MKMapRectGetMidY(mapRect));
	
	CLLocationCoordinate2D neCoordinate = MKCoordinateForMapPoint(neMapPoint);
	CLLocationCoordinate2D swCoordinate = MKCoordinateForMapPoint(swMapPoint);
	CLLocationCoordinate2D centerCoordinate = MKCoordinateForMapPoint(centerMapPoint);
	CLLocation *centerLocation = [[CLLocation alloc] initWithCoordinate:centerCoordinate altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
	
	if (CLLocationCoordinate2DIsValid(neCoordinate) && CLLocationCoordinate2DIsValid(swCoordinate) && CLLocationCoordinate2DIsValid(centerCoordinate)) {
		
		dispatch_async(self.annotationQueue, ^{
			NSPredicate *addressTypePredicate = [NSPredicate predicateWithFormat:@"addressType in %@", @[ @(SAGAddressTypePrimaryAddress), @(SAGAddressTypeDeliveryAddress) ]];
			NSPredicate *spatialPredicate = [self predicateWithNECoordinate:neCoordinate andSWCoordinate:swCoordinate];
			
			NSFetchRequest *request = [SBAddress MR_requestAllWithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[ addressTypePredicate, spatialPredicate ]]];
			request.fetchLimit = 50;
			NSArray *addresses = [SBAddress MR_executeFetchRequest:request];
			self.addresses = [addresses sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				if ([((SBAddress *)obj1).location distanceFromLocation:centerLocation] > [((SBAddress *)obj2).location distanceFromLocation:centerLocation]) {
					return (NSComparisonResult)NSOrderedDescending;
				}
				if ([((SBAddress *)obj1).location distanceFromLocation:centerLocation] < [((SBAddress *)obj2).location distanceFromLocation:centerLocation]) {
					return (NSComparisonResult)NSOrderedDescending;
				}
				return (NSComparisonResult)NSOrderedSame;
			}];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[mapView removeAnnotations:[self invisibleAnnotationsInMapView:mapView]];
				for (id<MKAnnotation> annotation in self.addresses) {
					if (![mapView.annotations containsObject:annotation]) {
						[mapView addAnnotation:annotation];
					}
				}
			});
		});
	}
}

- (NSArray *)visibleAnnotationsInMapView:(MKMapView *)mapView
{
	return [[mapView annotationsInMapRect:mapView.visibleMapRect] allObjects];
}

- (NSArray *)invisibleAnnotationsInMapView:(MKMapView *)mapView
{
	NSMutableArray *invisibles = [NSMutableArray arrayWithArray:[self annotationsWithoutUserLocationInMapView:mapView]];
	[invisibles removeObjectsInArray:[self visibleAnnotationsInMapView:mapView]];
	return invisibles;
}

- (NSArray *)annotationsWithoutUserLocationInMapView:(MKMapView *)mapView
{
	return [mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class = %@", [SBAddress class]]];
}

- (NSPredicate *)predicateWithNECoordinate:(CLLocationCoordinate2D)neCoordinate andSWCoordinate:(CLLocationCoordinate2D)swCoordinate
{
	NSArray *sortedLatitudes = [@[ @(neCoordinate.latitude), @(swCoordinate.latitude) ] sortedArrayUsingSelector:@selector(compare:)];
	NSArray *sortedLongitues = [@[ @(neCoordinate.longitude), @(swCoordinate.longitude) ] sortedArrayUsingSelector:@selector(compare:)];
	
	return [NSPredicate predicateWithFormat:@"addressType = %@ and latitude between %@ and longitude between %@",
			@(SAGAddressTypePrimaryAddress),
			@[ [NSExpression expressionForConstantValue:sortedLatitudes[0]], [NSExpression expressionForConstantValue:sortedLatitudes[1]] ],
			@[ [NSExpression expressionForConstantValue:sortedLongitues[0]], [NSExpression expressionForConstantValue:sortedLongitues[1]] ]];
}

@end
