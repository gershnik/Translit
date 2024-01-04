// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import <XCTest/XCTest.h>

#include "../src/TableRU.hpp"

@interface TestPerf : XCTestCase

@end

@implementation TestPerf

- (void)testPerformance {
    auto dataUrl = [[NSURL fileURLWithPath:@( __FILE__ )].URLByDeletingLastPathComponent URLByAppendingPathComponent:@"PerfData"];
    NSError * err;
    auto nsstr = [NSString stringWithContentsOfURL:dataUrl encoding:NSUTF8StringEncoding error:&err];
    XCTAssertNil(err);
    std::u16string str(nsstr.length, u'\0');
    [nsstr getCharacters:(unichar *)str.data()];

    auto mapper = g_mapperRu<std::ranges::subrange<std::u16string::const_iterator>>;
    
    __block volatile char16_t sink;
    __block intptr_t diff = 0;
    
    [self measureBlock:^{
        auto begin = str.begin();
        auto end = str.end();
        auto completed = begin;
        for (auto start = begin ; start != end; ) {
            auto res = mapper(std::ranges::subrange(start, end));
            if (res.payload) {
                //m_matchedSomething = true;
                //m_translit += res.payload;
                sink = *res.payload;
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
