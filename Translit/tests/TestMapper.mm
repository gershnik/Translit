// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "TestCommon.hpp"

#include "../src/Mapper.hpp"

using namespace std::literals;

@interface TestMapper : XCTestCase

@end

@implementation TestMapper


- (void)testOnlyEmptyString {
    auto mapper = makeMapper<std::u16string, 42, Mapping{0, u""}>();
    XCTAssertCppEqual(mapper(u""s), 0);
    XCTAssertCppEqual(mapper(u"a"s), 42);
}

- (void)testDisjointStrings {
    {
        auto mapper = makeMapper<std::u16string, 42, Mapping{0, u"b"}, Mapping{1, u"c"}, Mapping{2, u"a"}>();
        XCTAssertCppEqual(mapper(u""s), 42);
        XCTAssertCppEqual(mapper(u"a"s), 2);
        XCTAssertCppEqual(mapper(u"b"s), 0);
        XCTAssertCppEqual(mapper(u"c"s), 1);
        XCTAssertCppEqual(mapper(u" "s), 42);
    }
    
    {
        auto mapper = makeMapper<std::u16string, 42, Mapping{0, u"ef"}, Mapping{1, u"cd"}, Mapping{2, u"ab"}>();
        XCTAssertCppEqual(mapper(u""s), 42);
        XCTAssertCppEqual(mapper(u"a"s), 42);
        XCTAssertCppEqual(mapper(u"b"s), 42);
        XCTAssertCppEqual(mapper(u"cd"s), 1);
    }
    
}

- (void)testOverlappingStrings {
    {
        auto mapper = makeMapper<std::u16string, 42, Mapping{0, u"b"}, Mapping{1, u"bcd"}>();
        XCTAssertCppEqual(mapper(u"b"s), 0);
        XCTAssertCppEqual(mapper(u"bc"s), 42);
        XCTAssertCppEqual(mapper(u"bcd"s), 1);
    }
    {
        auto mapper = makeMapper<std::u16string, 42, Mapping{0, u"bc"}, Mapping{1, u"bd"}, Mapping{2, u"bdd"}>();
        XCTAssertCppEqual(mapper(u"b"s), 42);
        XCTAssertCppEqual(mapper(u"bc"s), 0);
        XCTAssertCppEqual(mapper(u"bd"s), 1);
        XCTAssertCppEqual(mapper(u"bdd"s), 2);
    }
    {
        auto mapper = makeMapper<std::string, 42, Mapping{0, "bd"}, Mapping{1, "bddq"}>();
        XCTAssertCppEqual(mapper("bd"s), 0);
        XCTAssertCppEqual(mapper("bddc"s), 42);
        XCTAssertCppEqual(mapper("bddq"s), 1);
    }
}

- (void)testRepeatedStrings {
    constexpr auto mapper = makeMapper<std::string_view, 42, Mapping{0, "ab"}, Mapping{1, "cd"}, Mapping{2, "ab"}>();
    XCTAssertCppEqual(mapper("ab"sv), 2);
    XCTAssertCppEqual(mapper("cd"sv), 1);
}


@end
