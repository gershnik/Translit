// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TRANSLITERATOR_HPP_INCLUDED
#define TRANSLIT_HEADER_TRANSLITERATOR_HPP_INCLUDED

#include "Mapper.hpp"

class Transliterator {
private:
    using Char = char16_t;
    using String = std::basic_string<Char>;
    using StringView = std::basic_string_view<Char>;
    using Iterator = String::const_iterator;
    using Range = std::ranges::subrange<Iterator>;
    using MappingFunc = PrefixMappingResult<Char, Iterator> (const Range &);
    
public:
    Transliterator(const NSStringCharAccess & name): m_mapper(getMapper(name))
    {}
    
    void append(const NSStringCharAccess & str);
    
    auto result() const -> StringView
        { return m_translit; }
    auto completedSize() const -> size_t
        { return m_translitCompletedSize; }
    auto matchedSomething() const -> bool
        { return m_matchedSomething; }
    
    void clear()  {
        m_prefix.clear();
        m_translit.clear();
        m_translitCompletedSize = 0;
        m_matchedSomething = false;
    }
    
    void clearCompleted() {
        m_translit.erase(m_translit.begin(), m_translit.begin() + m_translitCompletedSize);
        m_translitCompletedSize = 0;
        if (m_translit.empty())
            m_matchedSomething = false;
    }
    
private:
    static auto getMapper(const NSStringCharAccess & name) -> MappingFunc *;
    
private:
    MappingFunc * m_mapper = nullPrefixMapper<Char, Range>;
    
    String m_prefix;
    String m_translit;
    size_t m_translitCompletedSize = 0;
    bool m_matchedSomething = false;
};


#endif
