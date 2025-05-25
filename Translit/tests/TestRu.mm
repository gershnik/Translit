// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "TestCommon.hpp"


using namespace std::literals::string_view_literals;


@interface TestRu : XCTestCase

@end


@implementation TestRu {
    std::unique_ptr<Transliterator> _tr;
}

- (void)setUp {
    auto mapper = getMapperFor(@"ru", @"");
    _tr = std::make_unique<Transliterator>(mapper);
}

- (void)tearDown {
    _tr->clear();
}

- (void)testUnmapped {
    _tr->append(NSStringCharAccess(@" "));
    XCTAssertTranslit(*_tr, u" "sv, 1, false);
}

- (void)testSingle {
    
    _tr->append(NSStringCharAccess(@"a"));
    XCTAssertTranslit(*_tr, u"а"sv, 1, true);
    _tr->append(NSStringCharAccess(@"b"));
    XCTAssertTranslit(*_tr, u"аб"sv, 2, true);
}

- (void)testDoubleInterrupted {
    _tr->append(NSStringCharAccess(@"z"));
    XCTAssertTranslit(*_tr, u"з"sv, 0, true);
    _tr->append(NSStringCharAccess(@"."));
    XCTAssertTranslit(*_tr, u"з."sv, 2, true);
}

- (void)testDouble {
    _tr->append(NSStringCharAccess(@"z"));
    XCTAssertTranslit(*_tr, u"з"sv, 0, true);
    _tr->append(NSStringCharAccess(@"h"));
    XCTAssertTranslit(*_tr, u"ж"sv, 1, true);
}

- (void)testTripleInterrupted {
    _tr->append(NSStringCharAccess(@"s"));
    XCTAssertTranslit(*_tr, u"с"sv, 0, true);
    _tr->append(NSStringCharAccess(@"h"));
    XCTAssertTranslit(*_tr, u"ш"sv, 0, true);
    _tr->append(NSStringCharAccess(@" "));
    XCTAssertTranslit(*_tr, u"ш "sv, 2, true);
}

- (void)testTriple {
    _tr->append(NSStringCharAccess(@"s"));
    XCTAssertTranslit(*_tr, u"с"sv, 0, true);
    _tr->append(NSStringCharAccess(@"h"));
    XCTAssertTranslit(*_tr, u"ш"sv, 0, true);
    _tr->append(NSStringCharAccess(@"h"));
    XCTAssertTranslit(*_tr, u"щ"sv, 1, true);
}

@end
