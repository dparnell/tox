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
#import "net_crypto.h"

#pragma mark -
#pragma mark constants

NSString* kToxErrorDomain = @"ToxError";

NSString* kToxConnectedNotification = @"ToxConnected";
NSString* kToxDisconnectedNotification = @"ToxDisconnected";

NSString* kToxFriendRequestNotification = @"ToxFriendRequest";
NSString* kToxMessageNotification = @"ToxMessage";
NSString* kToxFriendNickChangedNotification = @"ToxFriendNickChanged";
NSString* kToxFriendStatusChangedNotification = @"ToxFriendStatusChanged";
NSString* kToxActionNotification = @"ToxAction";
NSString* kToxMessageReadNotification = @"ToxMessageRead";
NSString* kToxFriendRemovedNotification = @"ToxFriendRemoved";

NSString* kToxPublicKey = @"ToxPublicKey";
NSString* kToxMessageString = @"ToxMessageString";
NSString* kToxFriendNumber = @"ToxFriendNumber";
NSString* kToxNewFriendNick = @"ToxNewFriendNick";
NSString* kToxNewFriendStatus = @"ToxNewFriendStatus";
NSString* kToxNewFriendStatusKind = @"ToxNewFriendStatusKind";
NSString* kToxMessageNumber = @"ToxMessageNumber";
NSString* kToxFriendConnectionStatus = @"ToxFriendConnectionStatus";

NSString* kToxUserOnline = @"Online";
NSString* kToxUserAway = @"Away";
NSString* kToxUserBusy = @"Busy";
NSString* kToxUserOffline = @"Offline";
NSString* kToxUserInvalid = @"Invalid";


#pragma mark -
#pragma mark Code starts here

static ToxCore* instance = nil;

@implementation ToxCore {
    Messenger* messenger;
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
        messenger = initMessenger();
    }
    
    return self;
}

- (void)dealloc
{
    cleanupMessenger(messenger);
}

#pragma mark -
#pragma mark main code

static NSString* hex_string_from_public_key(uint8_t* public_key) {
    char tmp[FRIEND_ADDRESS_SIZE * 2 + 1];
    for(int i = 0; i < FRIEND_ADDRESS_SIZE; i++)
    {
        sprintf(&tmp[i*2], "%02X", public_key[i]);
    }
    
    return [NSString stringWithUTF8String: tmp];
    
}

static NSString* status_kind_to_string(USERSTATUS kind) {
    NSString* status_kind;
    
    switch (kind) {
        case USERSTATUS_NONE:
            status_kind = kToxUserOnline;
            break;
        case USERSTATUS_AWAY:
            status_kind = kToxUserAway;
            break;
        case USERSTATUS_BUSY:
            status_kind = kToxUserBusy;
            break;
        default:
            status_kind = kToxUserInvalid;
            break;
    }
    
    return status_kind;
}

#pragma mark -
#pragma mark Tox messenger callbacks

static void on_request(uint8_t* public_key, uint8_t* string, uint16_t length, void* user_data) {
    NSString* key = hex_string_from_public_key(public_key);
    NSData* data = [NSData dataWithBytes: string length: length];
    NSString* message = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxFriendRequestNotification
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 key, kToxPublicKey,
                                                                 message, kToxMessageString,
                                                                 nil]];
}

static void on_message(Messenger* m, int friendnumber, uint8_t* string, uint16_t length, void* user_data) {
    NSNumber* friend = [NSNumber numberWithInt: friendnumber];
    NSData* data = [NSData dataWithBytes: string length: length];
    NSString* message = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxMessageNotification
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 friend, kToxFriendNumber,
                                                                 message, kToxMessageString,
                                                                 nil]];
}

static void on_nickchange(Messenger* m, int friendnumber, uint8_t* string, uint16_t length, void* user_data) {
    NSNumber* friend = [NSNumber numberWithInt: friendnumber];
    NSData* data = [NSData dataWithBytes: string length: length];
    NSString* message = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxFriendNickChangedNotification
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 friend, kToxFriendNumber,
                                                                 message, kToxNewFriendNick,
                                                                 nil]];
}

static void on_userstatus(Messenger* m, int friendnumber, USERSTATUS kind, void* user_data) {
    NSNumber* friend = [NSNumber numberWithInt: friendnumber];
    NSString* status_kind = status_kind_to_string(kind);
    NSString* message = [instance friendStatus: friendnumber error: nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxFriendStatusChangedNotification
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 friend, kToxFriendNumber,
                                                                 message, kToxNewFriendStatus,
                                                                 status_kind, kToxNewFriendStatusKind,
                                                                 nil]];
}

static void on_statuschange(Messenger* m, int friendnumber, uint8_t* string, uint16_t length, void* user_data) {
    NSNumber* friend = [NSNumber numberWithInt: friendnumber];
    NSData* data = [NSData dataWithBytes: string length: length];
    NSString* message = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSString* status_kind = status_kind_to_string(m_get_userstatus(m, friendnumber));
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxFriendStatusChangedNotification
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 friend, kToxFriendNumber,
                                                                 message, kToxNewFriendStatus,
                                                                 status_kind, kToxNewFriendStatusKind,
                                                                 nil]];
}

static void on_action(Messenger* m, int friendnumber, uint8_t* string, uint16_t length, void* user_data) {
    NSNumber* friend = [NSNumber numberWithInt: friendnumber];
    NSData* data = [NSData dataWithBytes: string length: length];
    NSString* message = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxActionNotification
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 friend, kToxFriendNumber,
                                                                 message, kToxMessageString,
                                                                 nil]];
}

static void on_read(Messenger* m, int friendnumber, uint32_t message_number, void* user_data) {
    NSNumber* friend = [NSNumber numberWithInt: friendnumber];
    NSNumber* message_num = [NSNumber numberWithUnsignedInteger: message_number];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxMessageReadNotification
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 friend, kToxFriendNumber,
                                                                 message_num, kToxMessageNumber,
                                                                 nil]];
}

static void on_connectionstatus(Messenger* m, int friendnumber, uint8_t status, void* user_data) {
    NSNumber* friend = [NSNumber numberWithInt: friendnumber];
    NSNumber* con_stat = [NSNumber numberWithUnsignedChar: status];
    NSString* message = [instance friendStatus: friendnumber error: nil];
    NSString* status_kind = status_kind_to_string(m_get_userstatus(m, friendnumber));
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kToxFriendStatusChangedNotification
                                                        object: instance
                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 friend, kToxFriendNumber,
                                                                 message, kToxNewFriendStatus,
                                                                 status_kind, kToxNewFriendStatusKind,
                                                                 con_stat, kToxFriendConnectionStatus,
                                                                 nil]];
}

- (void) tick:(id)dummy {
    tick_count--;
    if(tick_count < 0 || !_connected) {
        tick_count = 200;
        
        BOOL is_connected = DHT_isconnected(messenger->dht);
        if(is_connected != _connected) {
            [self willChangeValueForKey: @"connected"];
            _connected = is_connected;
            [self didChangeValueForKey: @"connected"];
            
            if(_connected) {
                [[NSNotificationCenter defaultCenter] postNotificationName: kToxConnectedNotification object: self];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName: kToxDisconnectedNotification object: self];
            }
        }
    }
    
    doMessenger(messenger);
}

uint32_t resolve_addr(const char *address)
{
    struct addrinfo *server = NULL;
    struct addrinfo  hints;
    int              rc;
    uint32_t         addr;
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family   = AF_INET;    // IPv4 only right now.
    hints.ai_socktype = SOCK_DGRAM; // type of socket Tox uses.
    
    rc = getaddrinfo(address, "echo", &hints, &server);
    
    // Lookup failed.
    if (rc != 0) {
        return 0;
    }
    
    // IPv4 records only..
    if (server->ai_family != AF_INET) {
        freeaddrinfo(server);
        return 0;
    }
    
    
    addr = ((struct sockaddr_in *)server->ai_addr)->sin_addr.s_addr;
    
    freeaddrinfo(server);
    return addr;
}

- (BOOL) start:(NSURL*)url error:(NSError**)error{
    NSString* errorString = nil;
    
    if(timer) {
        // stop the existing timer
        [timer invalidate];
        timer = nil;
    }
    
    if([[url scheme] isEqualToString: @"dht"]) {
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
                                    
                    m_callback_friendrequest(messenger, on_request, (__bridge void *)(self));
                    m_callback_friendmessage(messenger, on_message, (__bridge void *)(self));
                    m_callback_namechange(messenger, on_nickchange, (__bridge void *)(self));
                    m_callback_statusmessage(messenger, on_statuschange, (__bridge void *)(self));
                    m_callback_userstatus(messenger, on_userstatus, (__bridge void *)(self));
                    m_callback_read_receipt(messenger, on_read,(__bridge void *)(self));
                    m_callback_connectionstatus(messenger, on_connectionstatus, (__bridge void *)(self));
                    
                    DHT_bootstrap(messenger->dht, bootstrap_ip_port, (uint8_t*)[[ToxCore dataFromHexString: [path lastPathComponent]] bytes]);
                    
                    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0f/20.0f target: self selector: @selector(tick:) userInfo: nil repeats: YES];
                
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
        *error = error_from_string(errorString);
    }
    
    return NO;
}

#pragma mark -
#pragma mark Communication methods

- (NSString*) clientIdForFriend:(int)friend_number error:(NSError**)error {
    uint8_t public_key[FRIEND_ADDRESS_SIZE];
    
    if(getclient_id(messenger, friend_number, public_key) == 0) {
        return hex_string_from_public_key(public_key);
    }
    
    if (error) {
        *error = error_from_string(@"Unknown friend");
    }
    return nil;    
}

- (NSString*) friendName:(int)friend_number error:(NSError**)error {
    char buffer[MAX_NAME_LENGTH+1];
    if(getname(messenger, friend_number, (uint8_t*)buffer) == 0) {
        NSString* result = [NSString stringWithUTF8String: buffer];
        
        if(result.length == 0) {
            uint8_t public_key[FRIEND_ADDRESS_SIZE];
            
            if(getclient_id(messenger, friend_number, public_key) == 0) {
                result = hex_string_from_public_key(public_key);
            }
        }
        
        if(result) {
            return result;
        }
    }
    
    if (error) {
        *error = error_from_string(@"Unknown friend");
    }
    return nil;
}

- (NSString*) friendStatus:(int)friend_number error:(NSError**)error {
    char buffer[128];
    if(m_copy_statusmessage(messenger, friend_number, (uint8_t*)buffer, sizeof(buffer)) == 0) {
        return [NSString stringWithUTF8String: buffer];
    }
    
    if (error) {
        *error = error_from_string(@"Unknown friend");
    }
    return nil;
}

- (int) friendStatusCode:(int)friend_number {
    return m_friendstatus(messenger, friend_number);
}

- (NSString*) friendStatusKind:(int)friend_number error:(NSError**)error {
    USERSTATUS kind = m_get_userstatus(messenger, friend_number);
    
    if(kind == USERSTATUS_INVALID) {
        if(error) {
            *error = error_from_string(@"Unknown friend");
        }
        return nil;
    }
    return status_kind_to_string(kind);
}

- (int) friendNumber:(NSString*)client_id error:(NSError**)error {
    NSString* errorString = nil;
    
    NSData* data = [ToxCore dataFromHexString: client_id];
    if(data) {
        int friend_num = getfriend_id(messenger, (uint8_t*)[data bytes]);
        if(friend_num >= 0) {
            return friend_num;
        }
        errorString = @"Unknown client_id";
    } else {
        errorString = @"Invalid client_id";
    }
    
    if(error) {
        *error = error_from_string(errorString);
    }
    return -1;
}

- (int) acceptFriendRequestFrom:(NSString*)client_id error:(NSError**)error {
    NSString* errorString = nil;
    
    NSData* data = [ToxCore dataFromHexString: client_id];
    if(data) {        
        return m_addfriend_norequest(messenger, (uint8_t*)[data bytes]);
    } else {
        errorString = @"Invalid client_id";
    }
    
    if(error) {
        *error = error_from_string(errorString);
    }
    return -1;
}

- (NSUInteger) sendMessage:(NSString*)text toFriend:(int)friend_number error:(NSError**)error {
    const char* utf = [text UTF8String];
    int result = m_sendmessage(messenger, friend_number, (uint8_t*)utf, (uint32_t)strlen(utf)+1);
    
    if(result == 0 && error) {
        *error = error_from_string(@"message send failed");
    }
        
    return result;
}

- (BOOL) sendAction:(NSString*)text toFriend:(int)friend_number error:(NSError**)error {
    const char* utf = [text UTF8String];
    
    if(m_sendaction(messenger, friend_number, (uint8_t*)utf, (uint32_t)strlen(utf)+1)) {
        return YES;
    }
    if(error) {
        *error = error_from_string(@"action send failed");
    }
    return NO;
}

- (BOOL) sendFriendRequestTo:(NSString*)client_id message:(NSString*)message error:(NSError**)error {
    NSString* errorString;
    
    if([client_id length] == FRIEND_ADDRESS_SIZE * 2) {
        NSData* data = [ToxCore dataFromHexString: client_id];
        if(data) {
            const char* utf = [message UTF8String];
            
            int result = m_addfriend(messenger, (uint8_t*)[data bytes], (uint8_t*)utf, strlen(utf)+1);
            if(result >= 0) {
                utf = [NSLocalizedString(@"Pending", @"Pending acceptance") UTF8String];
                on_statuschange(messenger, result, (uint8_t*)utf, strlen(utf)+1, (__bridge void *)(self));
                
                return YES;
            }
            
            switch(result) {
                case FAERR_TOOLONG:
                    errorString = @"Message is too long";
                    break;
                    
                case FAERR_NOMESSAGE:
                    errorString = @"Please add a message to your request";
                    break;
                    
                case FAERR_OWNKEY:
                    errorString = @"That appears to be your own ID";
                    break;
                    
                case FAERR_ALREADYSENT:
                    errorString = @"Friend request already sent";
                    break;
                    
                case FAERR_UNKNOWN:
                    errorString = @"Undefined error when adding friend";
                    break;
                    
                case FAERR_BADCHECKSUM:
                    errorString = @"Bad checksum in address";
                    break;
                    
                case FAERR_SETNEWNOSPAM:
                    errorString = @"Nospam was different";
                    break;
                    
                default:
                    errorString = @"Could not add new friend";
                    break;
            }
        } else {
            errorString = @"Invalid friend length";
        }
    } else {
        errorString = @"Wrong friend id length";
    }
    
    if(error) {
        *error = error_from_string(errorString);
    }

    return NO;
}

- (int) addFriendWithoutRequest:(NSString*)client_id error:(NSError**)error {
    NSString* errorString;
    
    NSData* data = [ToxCore dataFromHexString: client_id];
    if(data) {
        int friend_num = m_addfriend_norequest(messenger, (uint8_t*)[data bytes]);
        if(friend_num >= 0) {
            return friend_num;
        }
        
        errorString = @"Could not add friend";
    } else {
        errorString = @"Invalid client_id";
    }
    
    if(error) {
        *error = error_from_string(errorString);
    }
    
    return -1;
}

- (BOOL) removeFriend:(int)friend_number error:(NSError**)error {
    if(m_delfriend(messenger, friend_number) == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName: kToxFriendRemovedNotification
                                                            object: instance
                                                          userInfo: [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: friend_number] forKey: kToxFriendNumber]];
        return YES;
    }
    
    if(error) {
        *error = error_from_string(@"Could not remove friend");
    }
    
    return NO;
}

#pragma mark -
#pragma mark properties

- (NSString*) public_key {
    uint8_t address[FRIEND_ADDRESS_SIZE];
    getaddress(messenger, address);    
    char tmp[FRIEND_ADDRESS_SIZE * 2 + 1];
    for(int i = 0; i < FRIEND_ADDRESS_SIZE; i++)
    {
        sprintf(&tmp[i*2], "%02X",address[i]);
    }
    
    return [NSString stringWithUTF8String: tmp];
}

- (void) setUser_status:(NSString *)user_status {
    if(!user_status) {
        user_status = @"";
    }
    const char* utf = [user_status UTF8String];
    _user_status = user_status;
    m_set_statusmessage(messenger, (uint8_t*)utf, strlen(utf)+1);
}

- (NSString*) nick {
    uint8_t buffer[MAX_NAME_LENGTH+1];
    int length = getself_name(messenger, buffer, sizeof(buffer));
    NSData* data = [NSData dataWithBytes:buffer length: length];
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

- (void) setNick:(NSString *)nick {
    const char* utf = [nick UTF8String];
    setname(messenger, (uint8_t*)utf, strlen(utf)+1);
}

- (NSData*) state {
    uint8_t buffer[crypto_box_PUBLICKEYBYTES + crypto_box_SECRETKEYBYTES];
    
    save_keys(messenger->net_crypto, buffer);
    
    return [NSData dataWithBytes: buffer length: sizeof(buffer)];
}

- (void) setState:(NSData *)state {
    uint32_t L = (uint32_t)[state length];
    if(L == crypto_box_PUBLICKEYBYTES + crypto_box_SECRETKEYBYTES) {
        load_keys(messenger->net_crypto, (uint8_t*)[state bytes]);
    } else {
        Messenger_load(messenger, (uint8_t*)[state bytes], L);
    }
}

#pragma mark -
#pragma mark Utility methods

static NSError* error_from_string(NSString* errorString) {
    NSString* s = NSLocalizedString(errorString, errorString);
    
    return [NSError errorWithDomain: kToxErrorDomain code: 0 userInfo: [NSDictionary dictionaryWithObject: s forKey: NSLocalizedDescriptionKey]];
}

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
