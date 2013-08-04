//
//  ToxController.h
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToxController : NSObject

@property (weak) IBOutlet NSWindow* window;

@property (strong) NSString* nick;
@property (strong, nonatomic) NSString* status;
@property (assign) BOOL connected;
@property (strong) NSMutableArray* friends;
@property (strong) NSImage* status_icon;

@end
