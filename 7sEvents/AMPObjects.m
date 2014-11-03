//
//  AMPObjects.m
//  7sEvents
//
//  Created by Vladimir Rojas on 21/07/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "AMPObjects.h"

@implementation AMPObjects

-(NSMutableArray*)children
{
    if (!_children) {
        _children = [[NSMutableArray alloc] init];
    }
    return _children;
}

@end
