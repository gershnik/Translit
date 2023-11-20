// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "../src/TransliteratorRegistry.h"
#include "TestCommon.h"


using namespace std::literals::string_view_literals;


@interface TestRu : XCTestCase

@end


@implementation TestRu {
    Transliterator * _tr;
}

- (void)setUp {
    _tr = &getTransliterator(S("ru"));
}

- (void)tearDown {
    _tr->clear();
}

- (void)testUnmapped {
    _tr->append(S(" "));
    XCTAssertTranslit(*_tr, u" "sv, 1, false);
}

- (void)testSingle {
    
    _tr->append(S("a"));
    XCTAssertTranslit(*_tr, u"а"sv, 1, true);
    _tr->append(S("b"));
    XCTAssertTranslit(*_tr, u"аб"sv, 2, true);
}

- (void)testDoubleInterrupted {
    _tr->append(S("z"));
    XCTAssertTranslit(*_tr, u"з"sv, 0, true);
    _tr->append(S("."));
    XCTAssertTranslit(*_tr, u"з."sv, 2, true);
}

- (void)testDouble {
    _tr->append(S("z"));
    XCTAssertTranslit(*_tr, u"з"sv, 0, true);
    _tr->append(S("h"));
    XCTAssertTranslit(*_tr, u"ж"sv, 1, true);
}

@end
