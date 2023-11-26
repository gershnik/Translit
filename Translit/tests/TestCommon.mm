// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "TestCommon.hpp"

@implementation Result {
    ResultPayload _payload;
}


-(instancetype) initWithPayload:(ResultPayload)payload {
    
    self = [super init];
    if (self) {
        _payload = payload;
    }
    return self;
}

-(instancetype) initWithTransliterator:(const Transliterator &)tr {
    self = [super init];
    if (self) {
        _payload = ResultPayload{tr.result(), tr.completedSize(), tr.matchedSomething()};
    }
    return self;
}

-(BOOL) isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:self.class])
        return NO;
    return [self isEqualTo:other];
}


-(BOOL) isEqualTo:(Result *)other {
    return _payload == other->_payload;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"{%@, %zu, %@}", sys_string(_payload.all).ns_str(), size_t(_payload.completedSize), @( _payload.matchedSomething )];
}
    
@end
