// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TEST_COMMON_HPP_INCLUDED
#define TRANSLIT_HEADER_TEST_COMMON_HPP_INCLUDED

#include "../src/Transliterator.hpp"

#include <objc-helpers/XCTestUtil.h>


namespace std {
    template<class T>
    auto testDescription(const optional<T> & opt) {
        if (opt)
            return TestUtil::describeForTest(*opt);
        return @"std::nullopt";
    }
    
    inline auto testDescription(const u16string_view & str) {
        return [NSString stringWithCharacters:(const unichar *)str.data() length:str.size()];
    }
}


#define XCTAssertTranslit(tr, str, size, matched) ({ \
    XCTAssertCppEqual((tr).result(), (str)); \
    XCTAssertCppEqual((tr).completedSize(), (size)); \
    XCTAssertCppEqual((tr).matchedSomething(), (matched)); \
})


#endif
