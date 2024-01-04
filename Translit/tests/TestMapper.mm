// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import <XCTest/XCTest.h>

#include "../src/Mapper.hpp"

using namespace std::literals;

@interface TestMapper : XCTestCase

@end

@implementation TestMapper


- (void)testOnlyEmptyString {
    auto mapper = makeMapper<std::u16string, 42, Mapping{0, u""}>();
    XCTAssertEqual(mapper(u""s), 0);
    XCTAssertEqual(mapper(u"a"s), 42);
}

- (void)testDisjointStrings {
    {
        auto mapper = makeMapper<std::u16string, 42, Mapping{0, u"b"}, Mapping{1, u"c"}, Mapping{2, u"a"}>();
        XCTAssertEqual(mapper(u""s), 42);
        XCTAssertEqual(mapper(u"a"s), 2);
        XCTAssertEqual(mapper(u"b"s), 0);
        XCTAssertEqual(mapper(u"c"s), 1);
        XCTAssertEqual(mapper(u" "s), 42);
    }
    
    {
        auto mapper = makeMapper<std::u16string, 42, Mapping{0, u"ef"}, Mapping{1, u"cd"}, Mapping{2, u"ab"}>();
        XCTAssertEqual(mapper(u""s), 42);
        XCTAssertEqual(mapper(u"a"s), 42);
        XCTAssertEqual(mapper(u"b"s), 42);
        XCTAssertEqual(mapper(u"cd"s), 1);
    }
    
}

- (void)testOverlappingStrings {
    {
        auto mapper = makeMapper<std::u16string, 42, Mapping{0, u"b"}, Mapping{1, u"bcd"}>();
        XCTAssertEqual(mapper(u"b"s), 0);
        XCTAssertEqual(mapper(u"bc"s), 42);
        XCTAssertEqual(mapper(u"bcd"s), 1);
    }
    {
        auto mapper = makeMapper<std::u16string, 42, Mapping{0, u"bc"}, Mapping{1, u"bd"}, Mapping{2, u"bdd"}>();
        XCTAssertEqual(mapper(u"b"s), 42);
        XCTAssertEqual(mapper(u"bc"s), 0);
        XCTAssertEqual(mapper(u"bd"s), 1);
        XCTAssertEqual(mapper(u"bdd"s), 2);
    }
    {
        auto mapper = makeMapper<std::string, 42, Mapping{0, "bd"}, Mapping{1, "bddq"}>();
        XCTAssertEqual(mapper("bd"s), 0);
        XCTAssertEqual(mapper("bddc"s), 42);
        XCTAssertEqual(mapper("bddq"s), 1);
    }
}

- (void)testRepeatedStrings {
    constexpr auto mapper = makeMapper<std::string_view, 42, Mapping{0, "ab"}, Mapping{1, "cd"}, Mapping{2, "ab"}>();
    XCTAssertEqual(mapper("ab"sv), 2);
    XCTAssertEqual(mapper("cd"sv), 1);
}


@end
