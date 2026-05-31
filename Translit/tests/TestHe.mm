// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "TestCommon.hpp"


using namespace std::literals::string_view_literals;


@interface TestHe : XCTestCase

@end


@implementation TestHe {
    std::unique_ptr<Transliterator> _tr;
}

- (void)setUp {
    auto mapper = getMapperFor(@"he", @"");
    _tr = std::make_unique<Transliterator>(mapper);
}

- (void)tearDown {
    _tr->clear();
}

- (void)testUnmapped {
    _tr->append(NSStringCharAccess(@"1"));
    XCTAssertTranslit(*_tr, u"1"sv, 1, false);
}

- (void)testSingle {
    // 'a' has no extension in Hebrew, so it's committed immediately.
    _tr->append(NSStringCharAccess(@"a"));
    XCTAssertTranslit(*_tr, u"א"sv, 1, true);
    _tr->append(NSStringCharAccess(@"b"));
    XCTAssertTranslit(*_tr, u"אב"sv, 2, true);
}

- (void)testSingleSrcMultiCharDst {
    // 'W' maps to a two-codepoint grapheme cluster (שׁ = ש + shin dot).
    // The mapper produces both codepoints; completedSize counts UTF-16 units.
    _tr->append(NSStringCharAccess(@"W"));
    XCTAssertTranslit(*_tr, u"שׁ"sv, 2, true);
}

- (void)testMultiCharSrcMultiCharDst {
    // 'oeo' → 'וֺ' (two codepoints). 'o' is ambiguous because 'oeo' extends it.
    _tr->append(NSStringCharAccess(@"o"));
    XCTAssertTranslit(*_tr, u"ו"sv, 0, true);   // o → ו, but oeo could still match
    _tr->append(NSStringCharAccess(@"e"));
    XCTAssertTranslit(*_tr, u"ו"sv, 0, true);   // 'oe' is a prefix of oeo; ו stays buffered
    _tr->append(NSStringCharAccess(@"o"));
    XCTAssertTranslit(*_tr, u"וֺ"sv, 2, true);  // oeo → וֺ (vav + holam haser), definite
}

- (void)testAmbiguousVavInterrupted {
    // 'o' alone is matched as ו, but oeo could extend. Interrupting with
    // something the mapper can't continue commits the ו and processes the
    // next char independently.
    _tr->append(NSStringCharAccess(@"o"));
    XCTAssertTranslit(*_tr, u"ו"sv, 0, true);
    _tr->append(NSStringCharAccess(@"b"));
    XCTAssertTranslit(*_tr, u"וב"sv, 2, true);  // ו committed, then b → ב
}

- (void)testEAsBufferedPrefix {
    // 'e' has no mapping by itself; it's only the start of e-, e', e", e+.
    // The Transliterator buffers the literal 'e' while awaiting an extension.
    _tr->append(NSStringCharAccess(@"e"));
    XCTAssertTranslit(*_tr, u"e"sv, 0, true);
}

- (void)testGereshFromE {
    // e' → ׳ (geresh)
    _tr->append(NSStringCharAccess(@"e"));
    XCTAssertTranslit(*_tr, u"e"sv, 0, true);
    _tr->append(NSStringCharAccess(@"'"));
    XCTAssertTranslit(*_tr, u"׳"sv, 1, true);
}

- (void)testGereshGershayimOverlap {
    // 'G' → ׳ but extends to GG → ״. Tests the overlap-resolution path.
    _tr->append(NSStringCharAccess(@"G"));
    XCTAssertTranslit(*_tr, u"׳"sv, 0, true);   // G → ׳, GG could extend
    _tr->append(NSStringCharAccess(@"G"));
    XCTAssertTranslit(*_tr, u"״"sv, 1, true);   // GG → ״
}

- (void)testMaqaf {
    // e- → ־ (maqaf, Hebrew hyphen)
    _tr->append(NSStringCharAccess(@"e"));
    XCTAssertTranslit(*_tr, u"e"sv, 0, true);
    _tr->append(NSStringCharAccess(@"-"));
    XCTAssertTranslit(*_tr, u"־"sv, 1, true);
}

@end
