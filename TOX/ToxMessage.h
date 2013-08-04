//
//  ToxMessage.h
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToxMessage : NSObject

+ (ToxMessage*) newWithSender:(id)sender message:(NSString*)text;

@property (strong) id sender;
@property (strong) NSDate* received_at;
@property (strong) NSString* text;

@end
