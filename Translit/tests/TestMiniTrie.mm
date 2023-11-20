// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import <XCTest/XCTest.h>

#include "../src/MiniTrie.h"

@interface TestMiniTrie : XCTestCase

@end

@implementation TestMiniTrie

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testEmpty {
    MiniTrie<char> trie{};
    {
        const char * const str = "";
        auto res = trie.prefixMatch(str, str + strlen(str));
        XCTAssertEqual(res.index, trie.noMatch);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str);
    }
    {
        const char * const str = "a";
        auto res = trie.prefixMatch(str, str + strlen(str));
        XCTAssertEqual(res.index, trie.noMatch);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str);
    }
}

- (void)testOnlyEmptyString {
    auto trie = MiniTrie<char>::from({""});
    {
        const char * const str = "";
        auto res = trie.prefixMatch(str, str + strlen(str));
        XCTAssertEqual(res.index, 0);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str);
    }
    {
        const char * str = "a";
        auto res = trie.prefixMatch(str, str + strlen(str));
        XCTAssertEqual(res.index, 0);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str);
    }
}

- (void)testDisjointStrings {
    {
        
        auto trie = MiniTrie<char>::from({"b", "c", "a"});
        {
            const char * const str = "";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, trie.noMatch);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str);
        }
        {
            const char * const str = "a";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, 2);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + strlen(str));
        }
        {
            const char * const str = "b";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, 0);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + strlen(str));
        }
        {
            const char * const str = "c";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, 1);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + strlen(str));
        }
    }
    
    {
        auto trie = MiniTrie<char>::from({"ef", "cd", "ab"});
        {
            const char * const str = "";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, trie.noMatch);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str);
        }
        {
            const char * const str = "a";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, trie.noMatch);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str);
        }
        {
            const char * const str = "b";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, trie.noMatch);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str);
        }
        {
            const char * const str = "cd";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, 1);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + strlen(str));
        }
    }
    
}

- (void)testOverlappingStrings {
    {
        auto trie = MiniTrie<char>::from({"b", "bcd"});
        {
            const char * const str = "b";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, 0);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str + 1);
        }
        {
            const char * const str = "bc";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, 0);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str + 1);
        }
        {
            const char * const str = "bcd";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, 1);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + 3);
        }
    }
    {
        auto trie = MiniTrie<char>::from({"bc", "bd", "bdd"});
        {
            const char * const str = "b";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, trie.noMatch);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str);
        }
        {
            const char * const str = "bc";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, 0);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + 2);
        }
        {
            const char * const str = "bd";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, 1);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str + 2);
        }
        {
            const char * const str = "bdd";
            auto res = trie.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.index, 2);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + 3);
        }
    }
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
