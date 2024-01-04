// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import <XCTest/XCTest.h>

#include "../src/Mapper.hpp"

using namespace std::literals;

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
    {
        auto str = u""s;
        auto res = mapper(str);
        XCTAssertEqual(res.payload, std::nullopt);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str.begin());
    }
    {
        auto str = u"a"s;
        auto res = mapper(str);
        XCTAssertEqual(res.payload, std::nullopt);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str.begin());
    }
}

- (void)testOnlyEmptyString {
    auto mapper = makePrefixMapper<std::u16string, Mapping{0, u""}>();
    {
        auto str = u""s;
        auto res = mapper(str);
        XCTAssertEqual(res.payload, 0);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str.begin());
    }
    {
        auto str = u"a"s;
        auto res = mapper(str);
        XCTAssertEqual(res.payload, 0);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str.begin());
    }
}

- (void)testDisjointStrings {
    {
        
        auto mapper = makePrefixMapper<std::u16string, Mapping{0, u"b"}, Mapping{1, u"c"}, Mapping{2, u"a"}>();
        {
            auto str = u""s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, std::nullopt);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str.begin());
        }
        {
            auto str = u"a"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, 2);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str.end());
        }
        {
            auto str = u"b"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, 0);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str.end());
        }
        {
            auto str = u"c"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, 1);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str.end());
        }
        {
            auto str = u" "s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, std::nullopt);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str.begin());
        }
    }
    
    {
        auto mapper = makePrefixMapper<std::u16string, Mapping{0, u"ef"}, Mapping{1, u"cd"}, Mapping{2, u"ab"}>();
        {
            auto str = u""s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, std::nullopt);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str.begin());
        }
        {
            auto str = u"a"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, std::nullopt);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str.begin());
        }
        {
            auto str = u"b"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, std::nullopt);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str.begin());
        }
        {
            auto str = u"cd"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, 1);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str.end());
        }
    }
    
}

- (void)testOverlappingStrings {
    {
        auto mapper = makePrefixMapper<std::u16string, Mapping{0, u"b"}, Mapping{1, u"bcd"}>();
        {
            auto str = u"b"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, 0);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str.begin() + 1);
        }
        {
            auto str = u"bc"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, 0);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str.begin() + 1);
        }
        {
            auto str = u"bcd"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, 1);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str.begin() + 3);
        }
    }
    {
        auto mapper = makePrefixMapper<std::u16string, Mapping{0, u"bc"}, Mapping{1, u"bd"}, Mapping{2, u"bdd"}>();
        {
            auto str = u"b"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, std::nullopt);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str.begin());
        }
        {
            auto str = u"bc"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, 0);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str.begin() + 2);
        }
        {
            auto str = u"bd"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, 1);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str.begin() + 2);
        }
        {
            auto str = u"bdd"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, 2);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str.begin() + 3);
        }
    }
    {
        auto mapper = makePrefixMapper<std::string, Mapping{0, "bd"}, Mapping{1, "bddq"}>();
        {
            auto str = "bddc"s;
            auto res = mapper(str);
            XCTAssertEqual(res.payload, 0);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str.begin() + 2);
        }

    }
}

- (void)testRepeatedStrings {
    constexpr auto mapper = makePrefixMapper<std::string_view, Mapping{0, "ab"}, Mapping{1, "cd"}, Mapping{2, "ab"}>();
    
    {
        constexpr auto str = "ab"sv;
        auto res = mapper(str);
        XCTAssertEqual(res.payload, 2);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str.end());
    }
    {
        constexpr auto str = "cd"sv;
        auto res = mapper(str);
        XCTAssertEqual(res.payload, 1);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str.end());
    }
}


@end
