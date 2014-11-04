//
//  PayPalViewController.h
//  CFE Móvil
//
//  Created by Vladimir Rojas on 07/10/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"

@protocol PayPalDelegate <NSObject>

- (void)paymentSuccess;

@end

@interface PayPalViewController : UIViewController <PayPalPaymentDelegate, PayPalFuturePaymentDelegate, PayPalProfileSharingDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong, readwrite) NSString *environment;
@property (nonatomic, assign, readwrite) BOOL acceptCreditCards;
@property (nonatomic, strong, readwrite) NSString *resultText;
@property (nonatomic, strong) id<PayPalDelegate> delegate;

@end
