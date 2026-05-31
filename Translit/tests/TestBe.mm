// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "TestCommon.hpp"


using namespace std::literals::string_view_literals;


@interface TestBe : XCTestCase

@end


@implementation TestBe {
    std::unique_ptr<Transliterator> _tr;
}

- (void)setUp {
    auto mapper = getMapperFor(@"be", @"");
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

- (void)testShortU {
    // 'w' → 'ў' (short U, Belarusian-specific). No extension, definite immediately.
    _tr->append(NSStringCharAccess(@"w"));
    XCTAssertTranslit(*_tr, u"ў"sv, 1, true);
}

- (void)testI {
    // Belarusian uses 'і' (U+0456), not 'и' as in Russian.
    _tr->append(NSStringCharAccess(@"i"));
    XCTAssertTranslit(*_tr, u"і"sv, 1, true);
}

- (void)testSoftSignDefault {
    // In the default variant, 'q' → 'ь'. No extension (Belarusian has no Ъ).
    _tr->append(NSStringCharAccess(@"q"));
    XCTAssertTranslit(*_tr, u"ь"sv, 1, true);
}

- (void)testZhDouble {
    // 'z' → 'з', extends to 'zh' → 'ж'.
    _tr->append(NSStringCharAccess(@"z"));
    XCTAssertTranslit(*_tr, u"з"sv, 0, true);
    _tr->append(NSStringCharAccess(@"h"));
    XCTAssertTranslit(*_tr, u"ж"sv, 1, true);
}

@end
