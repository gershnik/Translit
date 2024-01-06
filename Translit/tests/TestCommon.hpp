// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TEST_COMMON_HPP_INCLUDED
#define TRANSLIT_HEADER_TEST_COMMON_HPP_INCLUDED

#include "../src/Transliterator.hpp"

#import <XCTest/XCTest.h>

#include <sstream>
#include <cxxabi.h>

namespace TestUtil {
    using std::to_string;
    
    template<class T>
    concept TestDescriptable = requires(const T & obj) {
        { testDescription(obj) } -> std::same_as<NSString *>;
    };
    
    
    template<class T>
    concept ToStringDescriptable = requires(T obj) {
        { to_string(obj) } -> std::same_as<std::string>;
    };
    
    
    template<class T>
    concept OStreamDescriptable = requires(T obj, std::ostream & str) {
        { str << obj };
    };
    
    inline auto demangle(const char * name) -> std::string {

        int status = 0;
        std::unique_ptr<char, void(*)(void*)> res {
            abi::__cxa_demangle(name, nullptr, nullptr, &status),
            std::free
        };
        return (status==0) ? res.get() : name ;
    }
    
    template<class T>
    auto describeForTest(const T & val) {
        if constexpr (TestDescriptable<T>) {
            return testDescription(val);
        }
        else if constexpr (ToStringDescriptable<T>) {
            using std::to_string;
            auto str = to_string(val);
            return @(str.c_str());
        } else if constexpr (OStreamDescriptable<T>) {
            std::ostringstream str;
            str << val;
            return @(str.str().c_str());
        } else {
            return [NSString stringWithFormat:@"%s object", demangle(typeid(T).name()).c_str()];
        }
    }
}

#define XCTPrimitiveAssertCpp(test, op, type, expression1, expressionStr1, expression2, expressionStr2, ...) \
({ \
    _XCT_TRY { \
        __typeof__(expression1) expressionValue1 = (expression1); \
        __typeof__(expression2) expressionValue2 = (expression2); \
        if (expressionValue1 != expressionValue2) { \
            _XCTRegisterFailure(test, _XCTFailureDescription(_XCTAssertion_Equal, 0, expressionStr1, expressionStr2, TestUtil::describeForTest(expressionValue1), TestUtil::describeForTest(expressionValue2)), __VA_ARGS__); \
        } \
    } \
    _XCT_CATCH (_XCTestCaseInterruptionException *interruption) { [interruption raise]; } \
    _XCT_CATCH (...) { \
        NSString *_xct_reason = _XCTGetCurrentExceptionReason(); \
        _XCTRegisterUnexpectedFailure(test, _XCTFailureDescription((type), 1, expressionStr1, expressionStr2, _xct_reason), __VA_ARGS__); \
    } \
})

#define XCTAssertCppEqual(expression1, expression2, ...) \
    XCTPrimitiveAssertCpp(nil, !=, _XCTAssertion_Equal, expression1, @#expression1, expression2, @#expression2, __VA_ARGS__)

#define XCTAssertCppNotEqual(expression1, expression2, ...) \
    XCTPrimitiveAssertCpp(nil, ==, _XCTAssertion_NotEqual, expression1, @#expression1, expression2, @#expression2, __VA_ARGS__)

#define XCTAssertCppGreaterThan(expression1, expression2, ...) \
    XCTPrimitiveAssertCpp(nil, <=, _XCTAssertion_GreaterThan, expression1, @#expression1, expression2, @#expression2, __VA_ARGS__)

#define XCTAssertCppGreaterThanOrEqual(expression1, expression2, ...) \
    XCTPrimitiveAssertCpp(nil, <, _XCTAssertion_GreaterThanOrEqual, expression1, @#expression1, expression2, @#expression2, __VA_ARGS__)

#define XCTAssertCppLessThan(expression1, expression2, ...) \
    XCTPrimitiveAssertCpp(nil, >=, _XCTAssertion_LessThan, expression1, @#expression1, expression2, @#expression2, __VA_ARGS__)

#define XCTAssertCppLessThanOrEqual(expression1, expression2, ...) \
    XCTPrimitiveAssertCpp(nil, >, _XCTAssertion_LessThanOrEqual, expression1, @#expression1, expression2, @#expression2, __VA_ARGS__)


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
