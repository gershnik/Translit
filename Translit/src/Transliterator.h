// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TRANSLITERATOR_H_INCLUDED
#define TRANSLIT_HEADER_TRANSLITERATOR_H_INCLUDED

#ifdef TRANSLIT_USE_TRIE
    #include "MiniTrie.h"
#else
    #include "StateMachine.h"
#endif


class Transliterator {
public:
    using SizeType = unsigned short;
private:
    #ifdef TRANSLIT_USE_TRIE
        using Trie = MiniTrie<char16_t, SizeType>;
    #else
        using StateMachineType = StateMachine<char16_t, SizeType>;
    #endif
public:
    Transliterator() = default;
    
    template<std::ranges::range Range>
    static auto from(Range && range) -> Transliterator
    requires(std::is_convertible_v<std::tuple_element_t<0, std::ranges::range_value_t<Range>>, char16_t> &&
             std::is_convertible_v<std::tuple_element_t<1, std::ranges::range_value_t<Range>>, const char16_t *>) {
        
#ifdef TRANSLIT_USE_TRIE
        std::vector<char16_t> replacements;
        Trie::Builder trieBuilder;
        
        if constexpr (std::ranges::random_access_range<Range>) {
            replacements.reserve(std::ranges::size(range));
            trieBuilder.reserve(std::ranges::size(range));
        }
        for(auto & [trans, src]: range) {
            auto idx = replacements.size();
            replacements.push_back(trans);
            trieBuilder.add(src, idx);
        }
        return Transliterator(std::move(replacements), trieBuilder.build());
#else
        return Transliterator(StateMachineType(range));
#endif
    }
    
    void append(const sys_string & str);
    
    auto result() const -> std::u16string_view
        { return m_translit; }
    auto completedSize() const -> SizeType
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
#ifdef TRANSLIT_USE_TRIE
    Transliterator(std::vector<char16_t> && replacements, Trie && trie):
        m_replacements(std::move(replacements)),
        m_trie(std::move(trie))
    {
//        #ifdef TRANSLIT_TESTING
//            std::cout << m_trie;
//        #endif
    }
#else
    Transliterator(StateMachineType && sm):
        m_sm(std::move(sm))
    {}
#endif
    
private:
#ifdef TRANSLIT_USE_TRIE
    std::vector<char16_t> m_replacements;
    Trie m_trie;
#else
    StateMachineType m_sm;
#endif
    
    std::u16string m_prefix;
    std::u16string m_translit;
    SizeType m_translitCompletedSize = 0;
    bool m_matchedSomething = false;
};

#endif
