//
//  ToxCore.h
//  TOX
//
//  Created by Daniel Parnell on 2/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToxCore : NSObject

+ (ToxCore*) instance;

- (void) start;

@property (readonly) NSData* key;
@property (readonly) NSString* public_key;

@end
