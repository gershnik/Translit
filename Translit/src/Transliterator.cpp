// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "Transliterator.h"


void Transliterator::append(const sys_string & str) {
    sys_string::char_access strAccess(str);
    m_prefix.append(strAccess.begin(), strAccess.end());
    m_translit.erase(m_translit.begin() + m_translitCompletedSize, m_translit.end());
    
    const auto begin = m_prefix.begin();
    const auto end = m_prefix.end();
    auto completed = begin;
    for (auto start = begin ; start != end; ) {
        auto res = m_sm.prefixMatch(start, end);
        if (res.successful) {
            m_matchedSomething = true;
            m_translit += res.payload;
            //if the result is not definite we don't know if a longer match is possible so bail out
            if (!res.definite)
                break;
            //otherwise mark it as completed and continue
            start = res.next;
            ++m_translitCompletedSize;
            completed = start;
        } else if (!res.definite) {
            //no match but could be with more input, bail out
            m_matchedSomething = true;
            m_translit.append(start, end);
            break;
        } else  {
            //no match and couldn't be
            //consume 1 untranslated char and continue
            m_translit += *start;
            ++start;
            ++m_translitCompletedSize;
            completed = start;
        }
    }
    m_prefix.erase(begin, completed);
    
}

