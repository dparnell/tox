//
//  ToxMessage.m
//  TOX
//
//  Created by Daniel Parnell on 4/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "ToxMessage.h"

@implementation ToxMessage

+ (ToxMessage*) newWithSender:(id)sender message:(NSString*)text {
    return [[ToxMessage alloc] initWithSender: sender message: text];
}

- (id) initWithSender:(id) sender message:(NSString*)text {
    self = [super init];
    
    if(self) {
        _sender = sender;
        _text = text;
        _received_at = [NSDate date];
    }
    
    return self;
}
@end
