// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "TestCommon.hpp"

#include "../src/Mapper.hpp"

using namespace std::literals;

#define XCTAssertPrefixMap(mapper, text, exp_payload, exp_definite, exp_next) ({ \
    auto str = text; \
    auto res = mapper(str); \
    XCTAssertCppEqual(res.payload, (exp_payload)); \
    XCTAssertCppEqual(res.definite, (exp_definite)); \
    XCTAssertCppEqual(res.next - str.begin(), (exp_next)); \
})

@interface TestPrefixMapper : XCTestCase

@end

@implementation TestPrefixMapper

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testEmpty {
    auto mapper = nullPrefixMapper<char16_t, std::u16string>;
    XCTAssertPrefixMap(mapper, u""s, std::nullopt, true, 0);
    XCTAssertPrefixMap(mapper, u"a"s, std::nullopt, true, 0);
}

- (void)testOnlyEmptyString {
    auto mapper = makePrefixMapper<std::u16string, Mapping{0, u""}>();
    XCTAssertPrefixMap(mapper, u""s, 0, true, 0);
    XCTAssertPrefixMap(mapper, u"a"s, 0, true, 0);
}

- (void)testDisjointStrings {
    {
        auto mapper = makePrefixMapper<std::u16string, Mapping{0, u"b"}, Mapping{1, u"c"}, Mapping{2, u"a"}>();
        XCTAssertPrefixMap(mapper, u""s, std::nullopt, false, 0);
        XCTAssertPrefixMap(mapper, u"a"s, 2, true, 1);
        XCTAssertPrefixMap(mapper, u"b"s, 0, true, 1);
        XCTAssertPrefixMap(mapper, u"c"s, 1, true, 1);
        XCTAssertPrefixMap(mapper, u" "s, std::nullopt, true, 0);
    }
    
    {
        auto mapper = makePrefixMapper<std::u16string, Mapping{0, u"ef"}, Mapping{1, u"cd"}, Mapping{2, u"ab"}>();
        XCTAssertPrefixMap(mapper, u""s, std::nullopt, false, 0);
        XCTAssertPrefixMap(mapper, u"a"s, std::nullopt, false, 0);
        XCTAssertPrefixMap(mapper, u"b"s, std::nullopt, true, 0);
        XCTAssertPrefixMap(mapper, u"cd"s, 1, true, 2);
    }
    
}

- (void)testOverlappingStrings {
    {
        auto mapper = makePrefixMapper<std::u16string, Mapping{0, u"b"}, Mapping{1, u"bcd"}>();
        XCTAssertPrefixMap(mapper, u"b"s, 0, false, 1);
        XCTAssertPrefixMap(mapper, u"bc"s, 0, false, 1);
        XCTAssertPrefixMap(mapper, u"bcd"s, 1, true, 3);
    }
    {
        auto mapper = makePrefixMapper<std::u16string, Mapping{0, u"bc"}, Mapping{1, u"bd"}, Mapping{2, u"bdd"}>();
        XCTAssertPrefixMap(mapper, u"b"s, std::nullopt, false, 0);
        XCTAssertPrefixMap(mapper, u"bc"s, 0, true, 2);
        XCTAssertPrefixMap(mapper, u"bd"s, 1, false, 2);
        XCTAssertPrefixMap(mapper, u"bdd"s, 2, true, 3);
    }
    {
        auto mapper = makePrefixMapper<std::string, Mapping{0, "bd"}, Mapping{1, "bddq"}>();
        XCTAssertPrefixMap(mapper, "bddc"s, 0, true, 2);
    }
}

- (void)testRepeatedStrings {
    constexpr auto mapper = makePrefixMapper<std::string_view, Mapping{0, "ab"}, Mapping{1, "cd"}, Mapping{2, "ab"}>();
    XCTAssertPrefixMap(mapper, "ab"sv, 2, true, 2);
    XCTAssertPrefixMap(mapper, "cd"sv, 1, true, 2);
}


@end
