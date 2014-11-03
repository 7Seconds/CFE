//
//  CoreLocationController.m
//  UNAM 360
//
//  Created by Vladimir on 10/12/11.
//  Copyright 2011 UNAM Mobile. All rights reserved.
//

#import "CoreLocationController.h"


@implementation CoreLocationController

@synthesize locMgr, delegate;

- (id)init {
	self = [super init];
	
	if(self != nil) {
		self.locMgr = [[CLLocationManager alloc] init];
		self.locMgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
		self.locMgr.delegate = self;
	}
	
	return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)]) {
		[self.delegate locationUpdate:newLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)]) {
		[self.delegate locationError:error];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	if ([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)]) {
		[self.delegate headingUpdate:newHeading];
	}
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration: (CLLocationManager *)manager {
	return TRUE;
}

@end
