//
//  ToxWelcomeWindowController.h
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ToxWelcomeWindowController : NSWindowController

@property (readonly) NSString* public_key;
@property (copy, nonatomic) NSString* nick;

@end
