// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "TestCommon.hpp"


using namespace std::literals::string_view_literals;


@interface TestLanguages : XCTestCase

@end


@implementation TestLanguages

//
// getVariantsForLanguage
//

- (void)testGetVariantsForKnownLanguage {
    auto ruVariants = getVariantsForLanguage(@"ru");
    XCTAssertCppEqual(ruVariants.size(), 2u);
    XCTAssertEqualObjects(ruVariants[0].name, @"");
    XCTAssertEqualObjects(ruVariants[1].name, @"translit-ru");
}

- (void)testGetVariantsForSingleVariantLanguage {
    // Hebrew currently has only the default variant.
    auto heVariants = getVariantsForLanguage(@"he");
    XCTAssertCppEqual(heVariants.size(), 1u);
    XCTAssertEqualObjects(heVariants[0].name, @"");
}

- (void)testGetVariantsForUnknownLanguageFallsBackToDefault {
    // An unrecognized language must fall through to the default (null-mapper) entry.
    auto variants = getVariantsForLanguage(@"xx");
    XCTAssertCppEqual(variants.size(), 1u);
    XCTAssertEqual(variants[0].mapper, Transliterator::nullMapper);
}

//
// getMapperFor
//

- (void)testGetMapperForKnownLanguageDefaultVariant {
    auto mapper = getMapperFor(@"ru", @"");
    Transliterator tr(mapper);
    tr.append(NSStringCharAccess(@"a"));
    XCTAssertCppEqual(tr.result(), u"а"sv);
}

- (void)testGetMapperForNilVariantTreatedAsEmpty {
    auto withNil = getMapperFor(@"ru", nil);
    auto withEmpty = getMapperFor(@"ru", @"");
    XCTAssertEqual(withNil, withEmpty);
}

- (void)testGetMapperForUnknownVariantFallsBackToDefault {
    // Hebrew has no 'translit-ru' variant — getMapperFor must fall back to
    // the language's default variant rather than e.g. the null mapper.
    auto fallback = getMapperFor(@"he", @"translit-ru");
    auto def      = getMapperFor(@"he", @"");
    XCTAssertEqual(fallback, def);
}

- (void)testGetMapperForUnknownLanguageReturnsNullMapper {
    auto mapper = getMapperFor(@"xx", @"");
    XCTAssertEqual(mapper, Transliterator::nullMapper);
}

//
// Cross-language semantics — guards the bug where a variant lookup for one
// language was accidentally applied to a different language. Same variant
// name across languages must select that language's own scheme.
//

- (void)testSameVariantNameYieldsLanguageSpecificMapper {
    // 'translit-ru' exists for ru, uk, and be. Each language's translit-ru
    // is its own scheme — not a reference to ru's. Verify via behavior:
    // 'q' is mapped differently across them.
    {
        Transliterator tr(getMapperFor(@"ru", @"translit-ru"));
        tr.append(NSStringCharAccess(@"q"));
        XCTAssertCppEqual(tr.result(), u"я"sv);       // ru/translit-ru: q → я
        XCTAssertCppEqual(tr.completedSize(), 1u);
    }
    {
        Transliterator tr(getMapperFor(@"uk", @"translit-ru"));
        tr.append(NSStringCharAccess(@"q"));
        XCTAssertCppEqual(tr.result(), u"щ"sv);       // uk/translit-ru: q → щ
        XCTAssertCppEqual(tr.completedSize(), 1u);
    }
}

- (void)testDefaultVariantDiffersFromNamedVariant {
    // 'q' has substantively different behavior between ru/default and
    // ru/translit-ru: default treats it as a prefix of 'qq' (→ ъ), while
    // translit-ru maps it directly to 'я'.
    {
        Transliterator tr(getMapperFor(@"ru", @""));
        tr.append(NSStringCharAccess(@"q"));
        XCTAssertCppEqual(tr.result(), u"ь"sv);
        XCTAssertCppEqual(tr.completedSize(), 0u);    // not committed; qq → ъ may extend
    }
    {
        Transliterator tr(getMapperFor(@"ru", @"translit-ru"));
        tr.append(NSStringCharAccess(@"q"));
        XCTAssertCppEqual(tr.result(), u"я"sv);
        XCTAssertCppEqual(tr.completedSize(), 1u);    // definite in this variant
    }
}

//
// Null mapper / default Transliterator
//

- (void)testNullMapperDoesNotMarkAsMatched {
    // A default-constructed Transliterator uses the null mapper, which lets
    // every keystroke fall through unchanged. matchedSomething() must stay
    // false so the IME tells macOS it did not handle the key.
    Transliterator tr;
    tr.append(NSStringCharAccess(@"hello"));
    XCTAssertCppEqual(tr.matchedSomething(), false);
    XCTAssertCppEqual(tr.result(), u"hello"sv);
    XCTAssertCppEqual(tr.completedSize(), 5u);
}

@end
