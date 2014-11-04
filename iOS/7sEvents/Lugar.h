//
//  Lugar.h
//  Telcel 360
//
//  Created by Vladimir on 05/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Lugar : NSObject {
	NSNumber *atm;
	NSString *calle;
	NSNumber *cp;
	NSString *colonia;
	NSString *estado;
	NSString *horario;
	NSNumber *kiosco;
	NSNumber *latitud;
	NSNumber *longitud;
	NSString *municipio;
	NSNumber *numero;
	NSString *referencias;
	NSString *title;
}

@property (nonatomic, retain) NSNumber *atm;
@property (nonatomic, retain) NSString *calle;
@property (nonatomic, retain) NSNumber *cp;
@property (nonatomic, retain) NSString *colonia;
@property (nonatomic, retain) NSString *estado;
@property (nonatomic, retain) NSString *horario;
@property (nonatomic, retain) NSNumber *kiosco;
@property (nonatomic, retain) NSNumber *latitud;
@property (nonatomic, retain) NSNumber *longitud;
@property (nonatomic, retain) NSString *municipio;
@property (nonatomic, retain) NSNumber *numero;
@property (nonatomic, retain) NSString *referencias;
@property (nonatomic, retain) NSString *title;

@end
