// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_MINI_TRIE_H_INCLUDED
#define TRANSLIT_HEADER_MINI_TRIE_H_INCLUDED

#include <vector>
#include <concepts>
#include <algorithm>
#include <string>
#include <string.h>
#include <stdint.h>
#include <assert.h>

#ifdef TRANSLIT_TESTING
    #include <iostream>
#endif

template<class Char, std::unsigned_integral LengthType = uint8_t, std::unsigned_integral PayloadType = uint8_t>
class MiniTrie {
    
public:
    static inline constexpr PayloadType noMatch = PayloadType(-1);
    
private:
    struct Node {
        LengthType length;
        LengthType firstChildOffset;
        LengthType nextSiblingOffset;
        PayloadType payload;
        Char chars[1];
    };

    struct BuildEntry {
        const Char * str;
        LengthType len;
        PayloadType index;

        friend auto operator<(const BuildEntry & lhs, const BuildEntry & rhs) noexcept {
            auto len = std::min(lhs.len, rhs.len);
            if (auto res = memcmp(lhs.str, rhs.str, len * sizeof(Char)); res != 0)
                return res < 0;
            return lhs.len < rhs.len;
        }
    };

    using BuildVector = std::vector<BuildEntry>;
    using BuildIterator = typename BuildVector::iterator;
    
    enum TraversalState {
        Blank,
        AfterFirstChild,
        AfterNextSibling
    };
    struct BuildStackEntry {
        BuildStackEntry(LengthType parOff, bool ch, BuildIterator f, BuildIterator l):
            first(f),
            lastMatching(f),
            last(l),
            parentOffset(parOff),
            child(ch),
            state(Blank)
        {}
        
        BuildIterator first;
        BuildIterator lastMatching;
        BuildIterator last;
        LengthType parentOffset;
        LengthType offset;
        bool child;
        TraversalState state;
    };
    
public:
    class Builder {
    public:
        void reserve(LengthType size) {
            m_buildVector.reserve(size);
        }
        void add(const Char * str, PayloadType payload) {
            m_empty = false;
            auto len = std::char_traits<Char>::length(str);
            if (!len) {
                m_minSize = 0;
                m_emptyPayload = payload;
                return;
            }
            assert(len < noMatch);
            BuildEntry entry{str, LengthType(len), payload};
            if (entry.len > m_maxSize)
                m_maxSize = entry.len;
            if (entry.len < m_minSize)
                m_minSize = entry.len;

            auto it = std::lower_bound(m_buildVector.begin(), m_buildVector.end(), entry);
            assert(it == m_buildVector.end() || it->len != entry.len || std::char_traits<Char>::compare(it->str, entry.str, it->len) != 0);
            m_buildVector.insert(it, entry);
        }
        
        auto build() -> MiniTrie {
            if (m_empty) {
                return MiniTrie();
            }
            
            std::vector<std::byte> data(sizeof(Node));
            auto * rootNode = reinterpret_cast<Node *>(data.data());
            rootNode->payload = m_emptyPayload;
            if (!m_buildVector.empty()) {
                std::vector<BuildStackEntry> stack;
                stack.emplace_back(LengthType(0), true, m_buildVector.begin(), m_buildVector.end());
                buildData(stack, data);
            }
            
            return MiniTrie(std::move(data), m_minSize, m_maxSize);
        }
        
    private:
        static void buildData(std::vector<BuildStackEntry> & stack, std::vector<std::byte> & data) {
            
            while(!stack.empty()) {
                
                auto & stackEntry = stack.back();
                
                switch(stackEntry.state) {
                    case Blank: {
                        
                        LengthType prefixSize = stackEntry.first->len;
                        for(++stackEntry.lastMatching; stackEntry.lastMatching != stackEntry.last; ++stackEntry.lastMatching) {
                            LengthType matchingSize = 0;
                            while(matchingSize < prefixSize) {
                                
                                if (stackEntry.lastMatching->str[matchingSize] != stackEntry.first->str[matchingSize])
                                    break;
                                
                                ++matchingSize;
                            }
                            if (matchingSize == 0)
                                break;
                            prefixSize = matchingSize;
                        }
                        
                        stackEntry.offset = (decltype(stackEntry.offset))data.size();
                        auto newSize = alignSize(stackEntry.offset + sizeof(Node) + (prefixSize - 1) * sizeof(Char), alignof(Node));
                        assert(newSize < size_t(std::numeric_limits<LengthType>::max()));
                        data.resize(newSize);
                        auto * newNode = reinterpret_cast<Node *>(&data[stackEntry.offset]);
                        auto * parent = reinterpret_cast<Node *>(&data[stackEntry.parentOffset]);
                        
                        newNode->length = prefixSize;
                        newNode->payload = (prefixSize == stackEntry.first->len ? stackEntry.first->index: noMatch);
                        memcpy(newNode->chars, stackEntry.first->str, prefixSize * sizeof(Char));
                        if (stackEntry.child)
                            parent->firstChildOffset = stackEntry.offset;
                        else
                            parent->nextSiblingOffset = stackEntry.offset;
                        
                        for(auto it = stackEntry.first; it != stackEntry.lastMatching; ++it) {
                            it->str += prefixSize;
                            it->len -= prefixSize;
                        }
                        if (!stackEntry.first->len)
                            ++stackEntry.first;
                    }
                    stackEntry.state = AfterFirstChild;
                    if (stackEntry.first != stackEntry.lastMatching) {
                        stack.emplace_back(stackEntry.offset, true, stackEntry.first, stackEntry.lastMatching);
                        continue;
                    }
                    [[fallthrough]];
                case AfterFirstChild:
                    stackEntry.state = AfterNextSibling;
                    
                    if (stackEntry.lastMatching != stackEntry.last) {
                        stack.emplace_back(stackEntry.offset, false, stackEntry.lastMatching, stackEntry.last);
                        continue;
                    }
                    [[fallthrough]];
                case AfterNextSibling:
                    stack.pop_back();
                }
            }
        }
    private:
        BuildVector m_buildVector;
        PayloadType m_emptyPayload = noMatch;
        bool m_empty = true;
        LengthType m_minSize = LengthType(-1);
        LengthType m_maxSize = 0;
    };

public:
    MiniTrie() = default;
    
    template<class ItF, class ItL>
    requires(std::is_convertible_v<typename std::iterator_traits<ItF>::iterator_category, std::input_iterator_tag> &&
            std::is_same_v<typename std::iterator_traits<ItF>::value_type, const Char *> &&
            std::equality_comparable_with<ItF, ItL>)
    static auto from(ItF first, ItL last) -> MiniTrie {
        Builder builder;
        if constexpr (std::is_convertible_v<typename std::iterator_traits<ItF>::iterator_category, std::random_access_iterator_tag>)
            builder.reserve(LengthType(last - first));
        
        for(PayloadType i = 0; first != last; ++i, ++first) {
            builder.add(*first, i);
        }
        
        return builder.build();
    }
    
    template<class ItF, class ItL>
    requires(std::is_convertible_v<typename std::iterator_traits<ItF>::iterator_category, std::input_iterator_tag> &&
             std::is_same_v<std::tuple_element_t<0, typename std::iterator_traits<ItF>::value_type>, const Char *> &&
             std::is_convertible_v<std::tuple_element_t<1, typename std::iterator_traits<ItF>::value_type>, LengthType> &&
             std::equality_comparable_with<ItF, ItL>)
    static auto from(ItF first, ItL last) -> MiniTrie {
        Builder builder;
        if constexpr (std::is_convertible_v<typename std::iterator_traits<ItF>::iterator_category, std::random_access_iterator_tag>)
            builder.reserve(LengthType(last - first));
        
        for( ; first != last; ++first) {
            auto & [str, payload] = *first;
            builder.add(str, payload);
        }
        
        return builder.build();
    }
    
    template<std::ranges::range Range>
    static auto from(const Range & cont) -> MiniTrie {
        return from(std::begin(cont), std::end(cont));
    }
    
    static auto from(std::initializer_list<const Char *> strings) -> MiniTrie {
        return from(strings.begin(), strings.end());
    }
    
    template<class It>
    struct PrefixMatchResult {
        /**
         End of match
         If index == noMatch always stays at the start of input
         */
        It next;
        /** the payload of the successfull match or noMatch */
        PayloadType index;
        /**
         Whether the answer is definite and won't change with larger input
         */
        bool definite;
    };
    
    template<class ItF, class ItL>
    requires(std::is_convertible_v<typename std::iterator_traits<ItF>::iterator_category, std::forward_iterator_tag> &&
            std::is_same_v<typename std::iterator_traits<ItF>::value_type, Char> &&
            std::equality_comparable_with<ItF, ItL>)
    auto prefixMatch(ItF first, ItL last) const noexcept -> PrefixMatchResult<ItF> {
        
        auto base = m_data.data();
        auto current = reinterpret_cast<const Node *>(base);
        
        if (!current)
            return {first, noMatch, true};
        
        PayloadType ret = current->payload;
        bool definite = true;
        if (!current->firstChildOffset)
            return {first, ret, true};
        current = reinterpret_cast<const Node *>(base + current->firstChildOffset);
        
        ItF start = first;
        for ( ; ; ) {
            
            auto res = std::mismatch(current->chars, current->chars + current->length, start, last);

            if (res.first != current->chars + current->length) {
                
                //since sibling nodes share no prefix if there is a partial match
                //there is no point in checking siblings - we are done.
                
                //if input is exhausted the result is not definite
                if (res.second == last) {
                    definite = false;
                    break;
                }
                //if we made only partial progress through input
                if (res.second != start) {
                    break;
                }
                
                if (!current->nextSiblingOffset)
                    break;
                
                current = reinterpret_cast<const Node *>(base + current->nextSiblingOffset);
                continue;
            }

            start = res.second;
            ret = current->payload;
            if (!current->firstChildOffset)
                break;
            current = reinterpret_cast<const Node *>(base + current->firstChildOffset);
        }
        
        return {ret != noMatch ? start : first, ret, definite};
    }

    #ifdef TRANSLIT_TESTING
        friend auto operator<<(std::ostream & str, const MiniTrie & rhs) -> std::ostream & {
            
            auto root = reinterpret_cast<const Node *>(rhs.m_data.data());
            str << "MiniTrie{\n";
            if (root)
                rhs.dump(str, 0, root);
            str << "}\n";
            return str;
        }

    #endif
    
    

private:
    
    MiniTrie(std::vector<std::byte> && data, LengthType minSize, LengthType maxSize):
        m_data(std::move(data)),
        m_minSize(minSize),
        m_maxSize(maxSize)
    {}

    #ifdef TRANSLIT_TESTING
        void dump(std::ostream & str, size_t offset, const Node * node) const {
            str << std::string(offset, ' ') << '"' << sys_string(node->chars, node->length) << "\" " << int(node->payload) << '\n';
            if (node->firstChildOffset)
                dump(str, offset + 2, reinterpret_cast<const Node *>(m_data.data() + node->firstChildOffset));
            if (node->nextSiblingOffset)
                dump(str, offset, reinterpret_cast<const Node *>(m_data.data() + node->nextSiblingOffset));
        };
    #endif
    
    // Round size up to next multiple of alignment.
    static constexpr auto alignSize(size_t s, size_t alignment) noexcept -> size_t {
        assert(s + alignment > s);
        return (s + alignment - 1) & ~(alignment - 1);
    }

private:
    std::vector<std::byte> m_data;
    LengthType m_minSize = 0;
    LengthType m_maxSize = 0;
};


#endif 
