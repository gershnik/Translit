// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import <XCTest/XCTest.h>

#include "../src/MiniTrie.h"
#include "../src/TableRU.h"

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

- (void)testPerformance {
    auto dataUrl = [[NSURL fileURLWithPath:@( __FILE__ )].URLByDeletingLastPathComponent URLByAppendingPathComponent:@"PerfData"];
    NSError * err;
    auto str = sys_string((NSString *)[NSString stringWithContentsOfURL:dataUrl encoding:NSUTF8StringEncoding error:&err]);
    XCTAssertNil(err);

    using Trie = MiniTrie<char16_t, unsigned short>;
    
    std::vector<char16_t> replacements;
    auto trie = [&] () {
        Trie::Builder trieBuilder;
        replacements.reserve(std::ranges::size(g_tableRu));
        trieBuilder.reserve(std::ranges::size(g_tableRu));
        for(auto & [trans, src]: g_tableRu) {
            auto idx = replacements.size();
            replacements.push_back(trans);
            trieBuilder.add(src, idx);
        }
        return trieBuilder.build();
    }();
    
    __block volatile char16_t sink;
    __block intptr_t diff = 0;
    
    [self measureBlock:^{
        auto acess = sys_string::char_access(str);
        auto begin = acess.begin();
        auto end = acess.end();
        auto completed = begin;
        for (auto start = begin ; start != end; ) {
            auto res = trie.prefixMatch(start, end);
            if (res.index != Trie::noMatch) {
                //m_matchedSomething = true;
                //m_translit += m_replacements[res.index];
                sink = replacements[res.index];
                //if the result is not definite we don't know if a longer match is possible so bail out
                if (!res.definite)
                    break;
                //otherwise mark it as completed and continue
                start = res.next;
                //++m_translitCompletedSize;
                completed = start;
            } else if (!res.definite) {
                //no match but could be with more input, bail out
                //m_matchedSomething = true;
                //m_translit.append(start, end);
                for(auto it = start; it != end; ++it)
                    sink = *it;
                break;
            } else  {
                //no match and couldn't be
                //consume 1 untranslated char and continue
                //m_translit += *start;
                sink = *start;
                ++start;
                //++m_translitCompletedSize;
                completed = start;
            }
        }
        diff = end - completed;
    }];
    XCTAssertTrue(diff >= 0 && diff < 2);
}

@end
