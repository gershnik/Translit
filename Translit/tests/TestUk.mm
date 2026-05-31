// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "TestCommon.hpp"


using namespace std::literals::string_view_literals;


@interface TestUk : XCTestCase

@end


@implementation TestUk {
    std::unique_ptr<Transliterator> _tr;
}

- (void)setUp {
    auto mapper = getMapperFor(@"uk", @"");
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

- (void)testGheWithUpturn {
    // 'g' → 'г', but 'gg' extends to 'ґ' (ghe with upturn, Ukrainian-specific).
    _tr->append(NSStringCharAccess(@"g"));
    XCTAssertTranslit(*_tr, u"г"sv, 0, true);  // g could extend
    _tr->append(NSStringCharAccess(@"g"));
    XCTAssertTranslit(*_tr, u"ґ"sv, 1, true);  // gg → ґ
}

- (void)testYi {
    // 'j' → 'й', extends to 'ji' → 'ї' (yi, Ukrainian-specific).
    _tr->append(NSStringCharAccess(@"j"));
    XCTAssertTranslit(*_tr, u"й"sv, 0, true);  // j could extend (je, ji)
    _tr->append(NSStringCharAccess(@"i"));
    XCTAssertTranslit(*_tr, u"ї"sv, 1, true);  // ji → ї
}

- (void)testYe {
    // 'y' is 'и' in Ukrainian (vs Russian where 'y' is 'ы').
    // 'ye' extends to 'є' (Ukrainian-specific).
    _tr->append(NSStringCharAccess(@"y"));
    XCTAssertTranslit(*_tr, u"и"sv, 0, true);  // y could extend (ye, yu, ya)
    _tr->append(NSStringCharAccess(@"e"));
    XCTAssertTranslit(*_tr, u"є"sv, 1, true);  // ye → є
}

- (void)testYInterrupted {
    // 'y' alone, followed by something that doesn't extend, commits 'и'.
    _tr->append(NSStringCharAccess(@"y"));
    XCTAssertTranslit(*_tr, u"и"sv, 0, true);
    _tr->append(NSStringCharAccess(@"b"));
    XCTAssertTranslit(*_tr, u"иб"sv, 2, true);  // и committed, b → б
}

@end
