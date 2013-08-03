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

#pragma mark -
#pragma mark constants

NSString* kToxErrorDomain = @"ToxError";

NSString* kToxConnected = @"ToxConnected";
NSString* kToxDisconnected = @"ToxDisconnected";

NSString* kToxFriendRequest = @"ToxFriendRequest";
NSString* kToxMessage = @"ToxMessage";
NSString* kToxFriendNickChanged = @"ToxFriendNickChanged";
NSString* kToxFriendStatusChanged = @"ToxFriendStatusChanged";

NSString* kToxPublicKey = @"ToxPublicKey";
NSString* kToxMessageString = @"ToxMessageString";
NSString* kToxFriendNumber = @"ToxFriendNumber";
NSString* kToxNewFriendNick = @"ToxNewFriendNick";
NSString* kToxNewFriendStatus = @"ToxNewFriendStatus";

#pragma mark -
#pragma mark Code starts here

static ToxCore* instance = nil;

@implementation ToxCore {
    BOOL _connected;
    
    NSInteger tick_count;
    NSTimer* timer;
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
        tick_count = 0;
        _connected = NO;
        
        [self setupEncryption];
    }
    
    return self;
}

- (void) setupEncryption {
    NSData* stateData = [SSKeychain passwordDataForService: kToxService account: kToxAccount];
    if(stateData) {
        Messenger_load((uint8_t*)[stateData bytes], (uint32_t)[stateData length]);
    } else {
        // there is no key, so we will use the one that is created automatically by the initMessenger function
        [self  saveState];
    }
}

#pragma mark -
#pragma mark main code

void on_request(uint8_t* public_key, uint8_t* string, uint16_t length) {
    char tmp[PUB_KEY_BYTES * 2 + 1];
    for(int i = 0; i < PUB_KEY_BYTES; i++)
    {
        sprintf(&tmp[i*2], "%02X", public_key[i]);
    }
    
    NSString* key = [NSString stringWithUTF8String: tmp];
    NSData* data = [NSData dataWithBytes: string length: length];
    NSString* message = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxFriendRequest
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 key, kToxPublicKey,
                                                                 message, kToxMessageString,
                                                                 nil]];
}

void on_message(int friendnumber, uint8_t* string, uint16_t length) {
    NSNumber* friend = [NSNumber numberWithInt: friendnumber];
    NSData* data = [NSData dataWithBytes: string length: length];
    NSString* message = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxMessage
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 friend, kToxFriendNumber,
                                                                 message, kToxMessageString,
                                                                 nil]];
}

void on_nickchange(int friendnumber, uint8_t* string, uint16_t length) {
    NSNumber* friend = [NSNumber numberWithInt: friendnumber];
    NSData* data = [NSData dataWithBytes: string length: length];
    NSString* message = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxFriendNickChanged
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 friend, kToxFriendNumber,
                                                                 message, kToxNewFriendNick,
                                                                 nil]];
}

void on_statuschange(int friendnumber, uint8_t* string, uint16_t length) {
    NSNumber* friend = [NSNumber numberWithInt: friendnumber];
    NSData* data = [NSData dataWithBytes: string length: length];
    NSString* message = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxFriendStatusChanged
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 friend, kToxFriendNumber,
                                                                 message, kToxNewFriendStatus,
                                                                 nil]];
}

- (void) tick:(id)dummy {
    tick_count--;
    if(tick_count < 0 || !_connected) {
        tick_count = 200;
        
        BOOL is_connected = DHT_isconnected();
        if(is_connected != _connected) {
            [self willChangeValueForKey: @"connected"];
            _connected = is_connected;
            [self didChangeValueForKey: @"connected"];
            
            if(_connected) {
                [[NSNotificationCenter defaultCenter] postNotificationName: kToxConnected object: self];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName: kToxDisconnected object: self];
            }
        }
    }
    
    doMessenger();
}

- (BOOL) start:(NSURL*)url error:(NSError**)error{
    NSString* errorString = nil;
    
    if(timer) {
        // stop the existing timer
        [timer invalidate];
        timer = nil;
    }
    
    if([[url scheme] isEqualToString: @"tox"]) {
        NSNumber* port = [url port];
        if(!port) {
            port = [NSNumber numberWithInt: 33445];
        }
        
        NSString* host = [url host];
        if(host) {
            NSString* path = [url path];
            if(path) {
                IP_Port bootstrap_ip_port;
                bootstrap_ip_port.port = htons([port intValue]);
                int resolved_address = resolve_addr([host UTF8String]);
                if (resolved_address != 0) {
                    bootstrap_ip_port.ip.i = resolved_address;
                                    
                    m_callback_friendrequest(on_request);
                    m_callback_friendmessage(on_message);
                    m_callback_namechange(on_nickchange);
                    m_callback_userstatus(on_statuschange);
                                    
                    DHT_bootstrap(bootstrap_ip_port, (uint8_t*)[[ToxCore dataFromHexString: [path lastPathComponent]] bytes]);
                    
                    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0f/200.0f target: self selector: @selector(tick:) userInfo: nil repeats: YES];
                
                    return YES;
                    
                } else {
                    errorString = @"host not found";
                }
            } else {
                errorString = @"public key not specified";
            }
        } else {
            errorString = @"host not specified";
        }
    } else {
        errorString = @"invalid URL scheme";
    }
    
    if(error) {
        *error = [NSError errorWithDomain: kToxErrorDomain code: 0 userInfo: [NSDictionary dictionaryWithObject: errorString forKey: NSLocalizedDescriptionKey]];
    }
    
    return NO;
}

- (void) saveState {
    int size = Messenger_size();
    uint8_t data[size];
    Messenger_save(data);
    NSData* stateData = [NSData dataWithBytes: &data length: size];
    [SSKeychain setPasswordData: stateData forService: kToxService account: kToxAccount];    
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

#pragma mark -
#pragma mark Utility methods

+ (NSData*) dataFromHexString:(NSString*)string {
    uint8_t* buf;
    NSUInteger L = [string length];
    char byte_chars[3] = {'\0','\0','\0'};
    NSData* result;
    
    buf = malloc(L*2);
    for (int i=0; i < L/2; i++) {
        byte_chars[0] = [string characterAtIndex:i*2];
        byte_chars[1] = [string characterAtIndex:i*2+1];
        buf[i] = strtol(byte_chars, NULL, 16);
    }
    
    result = [NSData dataWithBytes: buf length: L/2];
    free(buf);
    
    return result;
}


@end
