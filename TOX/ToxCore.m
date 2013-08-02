//
//  ToxCore.m
//  TOX
//
//  Created by Daniel Parnell on 2/08/13.
//  Copyright (c) 2013 Daniel Parnell. All rights reserved.
//

#import "ToxCore.h"
#import "Messenger.h"
#import "network.h"
#import "SSKeychain.h"

#define PUB_KEY_BYTES 32

static NSString* kToxService = @"TOX";
static NSString* kToxAccount = @"Account";

static ToxCore* instance = nil;

@implementation ToxCore {
    NSData* _key;
}

#pragma mark -
#pragma mark Initialization

+ (ToxCore*) instance {
    if(instance == nil) {
        instance = [ToxCore new];
    }
    
    return instance;
}

- (id) init {
    self = [super init];
    if(self) {
        initMessenger();
        
        [self setupEncryption];
    }
    
    return self;
}

- (void) setupEncryption {
    NSData* keyData = [SSKeychain passwordDataForService: kToxService account: kToxAccount];
    if(keyData) {
        Messenger_load((uint8_t*)[keyData bytes], (uint32_t)[keyData length]);
    } else {
        // there is no key, so we need to make one
        int size = Messenger_size();
        uint8_t data[size];
        Messenger_save(data);
        keyData = [NSData dataWithBytes: &data length: size];
        [SSKeychain setPasswordData: keyData forService: kToxService account: kToxAccount];
    }
    
    _key = keyData;
}

- (void) start {
    
}

#pragma mark -
#pragma mark properties

- (NSString*) public_key {
    char tmp[PUB_KEY_BYTES * 2 + 1];
    for(int i = 0; i < PUB_KEY_BYTES; i++)
    {
        sprintf(&tmp[i*2], "%02X",self_public_key[i]);
    }
    
    return [NSString stringWithUTF8String: tmp];
}

@end
