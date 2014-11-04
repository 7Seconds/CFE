//
//  AMPObjects.h
//  7sEvents
//
//  Created by Vladimir Rojas on 21/07/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMPObjects : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *parent;
@property (nonatomic) BOOL canBeExpanded;
@property (nonatomic) BOOL isExpanded;
@property (nonatomic) BOOL isChildren;
@property (nonatomic) NSInteger level;
@property (nonatomic) NSInteger indexSection;
@property (nonatomic) NSInteger indexRow;
@property (nonatomic, strong) NSMutableArray *children;

@end