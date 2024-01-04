// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TEST_COMMON_HPP_INCLUDED
#define TRANSLIT_HEADER_TEST_COMMON_HPP_INCLUDED

#include "../src/Transliterator.hpp"

#import <XCTest/XCTest.h>

struct ResultPayload {
    ResultPayload() = default;
    ResultPayload(std::u16string_view all_,
                  size_t completedSize_,
                  bool matchedSomething_):
        all(all_),
        completedSize(completedSize_),
        matchedSomething(matchedSomething_)
    {}
    
    std::u16string_view all;
    size_t completedSize;
    bool matchedSomething;
    
    friend bool operator==(const ResultPayload &, const ResultPayload &) = default;
    friend bool operator!=(const ResultPayload &, const ResultPayload &) = default;
};

@interface Result : NSObject
-(instancetype) initWithPayload:(ResultPayload)payload ;
-(instancetype) initWithTransliterator:(const Transliterator &)tr;
@end

#define XCTAssertTranslit(tr, str, size, matched) \
    XCTAssertEqualObjects([[Result alloc] initWithTransliterator:tr], \
                          [[Result alloc] initWithPayload:ResultPayload((str), (size), (matched))]);



#endif
