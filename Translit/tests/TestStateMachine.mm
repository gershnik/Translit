// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import <XCTest/XCTest.h>

#include "../src/StateMachine.h"
#include "../src/TableRU.h"

@interface TestStateMachine : XCTestCase

@end

@implementation TestStateMachine

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testEmpty {
    StateMachine<char, uint8_t, uint8_t> sm;
    {
        const char * const str = "";
        auto res = sm.prefixMatch(str, str + strlen(str));
        XCTAssertEqual(res.successful, false);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str);
    }
    {
        const char * const str = "a";
        auto res = sm.prefixMatch(str, str + strlen(str));
        XCTAssertEqual(res.successful, false);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str);
    }
}

- (void)testOnlyEmptyString {
    StateMachine<char, uint8_t, uint8_t> sm({{0, ""}});
    {
        const char * const str = "";
        auto res = sm.prefixMatch(str, str + strlen(str));
        XCTAssertEqual(res.successful, true);
        XCTAssertEqual(res.payload, 0);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str);
    }
    {
        const char * str = "a";
        auto res = sm.prefixMatch(str, str + strlen(str));
        XCTAssertEqual(res.successful, true);
        XCTAssertEqual(res.payload, 0);
        XCTAssertEqual(res.definite, true);
        XCTAssertEqual(res.next, str);
    }
}

- (void)testDisjointStrings {
    {
        
        StateMachine<char, uint8_t, uint8_t> sm({{0, "b"}, {1, "c"}, {2, "a"}});
        {
            const char * const str = "";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, false);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str);
        }
        {
            const char * const str = "a";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, true);
            XCTAssertEqual(res.payload, 2);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + strlen(str));
        }
        {
            const char * const str = "b";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, true);
            XCTAssertEqual(res.payload, 0);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + strlen(str));
        }
        {
            const char * const str = "c";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, true);
            XCTAssertEqual(res.payload, 1);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + strlen(str));
        }
        {
            const char * const str = " ";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, false);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str);
        }
    }
    
    {
        StateMachine<char, uint8_t, uint8_t> sm({{0, "ef"}, {1, "cd"}, {2, "ab"}});
        {
            const char * const str = "";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, false);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str);
        }
        {
            const char * const str = "a";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, false);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str);
        }
        {
            const char * const str = "b";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, false);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str);
        }
        {
            const char * const str = "cd";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, true);
            XCTAssertEqual(res.payload, 1);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + strlen(str));
        }
    }
    
}

- (void)testOverlappingStrings {
    {
        StateMachine<char, uint8_t, uint8_t> sm({{0, "b"}, {1, "bcd"}});
        {
            const char * const str = "b";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, true);
            XCTAssertEqual(res.payload, 0);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str + 1);
        }
        {
            const char * const str = "bc";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, true);
            XCTAssertEqual(res.payload, 0);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str + 1);
        }
        {
            const char * const str = "bcd";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, true);
            XCTAssertEqual(res.payload, 1);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + 3);
        }
    }
    {
        StateMachine<char, uint8_t, uint8_t> sm({{0, "bc"}, {1, "bd"}, {2, "bdd"}});
        {
            const char * const str = "b";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, false);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str);
        }
        {
            const char * const str = "bc";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, true);
            XCTAssertEqual(res.payload, 0);
            XCTAssertEqual(res.definite, true);
            XCTAssertEqual(res.next, str + 2);
        }
        {
            const char * const str = "bd";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, true);
            XCTAssertEqual(res.payload, 1);
            XCTAssertEqual(res.definite, false);
            XCTAssertEqual(res.next, str + 2);
        }
        {
            const char * const str = "bdd";
            auto res = sm.prefixMatch(str, str + strlen(str));
            XCTAssertEqual(res.successful, true);
            XCTAssertEqual(res.payload, 2);
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

    StateMachine<char16_t, unsigned short> sm(g_tableRu);
    
    __block volatile char16_t sink;
    __block intptr_t diff = 0;
    
    [self measureBlock:^{
        auto acess = sys_string::char_access(str);
        auto begin = acess.begin();
        auto end = acess.end();
        auto completed = begin;
        for (auto start = begin ; start != end; ) {
            auto res = sm.prefixMatch(start, end);
            if (res.successful) {
                //m_matchedSomething = true;
                //m_translit += res.payload;
                sink = res.payload;
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
