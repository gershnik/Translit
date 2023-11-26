// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_STATE_MACHINE_H_INCLUDED
#define TRANSLIT_HEADER_STATE_MACHINE_H_INCLUDED

#include <ranges>
#include <optional>
#include <map>
#include <vector>
#include <string>
#include <functional>


template<class Char, std::unsigned_integral LengthType = uint8_t, class PayloadType = Char>
class StateMachine {
    
private:
    static inline constexpr LengthType noTransition = LengthType(-1);
    
private:
    struct Outcome {
        PayloadType payload;
        bool successful: 1;
        bool final: 1;
    };
    enum class OutcomeType {
        final,
        nonfinal,
        intermediate
    };
    struct OutcomeDescriptor {
        OutcomeDescriptor(LengthType idx_, OutcomeType type_, PayloadType payload_):
            idx(idx_), type(type_), payload(payload_)
        {}
        LengthType idx;
        OutcomeType type;
        PayloadType payload;
    };
    
    struct Expanded {
        std::vector<Char> inputs;
        std::vector<Outcome> outcomes;
        std::vector<LengthType> transitions;
    };

public:
    template<std::ranges::range Range, class Extractor = std::identity>
    requires(std::is_convertible_v<std::tuple_element_t<0, std::ranges::range_value_t<Range>>, PayloadType> &&
             std::is_convertible_v<std::tuple_element_t<1, std::ranges::range_value_t<Range>>, const Char *>)
    StateMachine(Range && range) {
        
        if (std::ranges::empty(range))
            return;
        
        Expanded expanded;
        
        //Step 1: Populate inputs and map of input sequences to outcomes and "empty outcome"
        std::map<std::basic_string<Char>, OutcomeDescriptor> outcomesMap;
        size_t terminalCount = 1;
        OutcomeDescriptor emptyOutcome{noTransition, OutcomeType::intermediate, PayloadType{}};
        
        for(auto [dst, src]: range) {
            
            if (!*src) {
                assert(emptyOutcome.type == OutcomeType::intermediate);
                emptyOutcome.type = OutcomeType::final;
                emptyOutcome.payload = dst;
                continue;
            }
            
            for(const Char * p = src; *p; ++p) {
                
                {
                    const Char input = *p;
                    auto it = std::lower_bound(expanded.inputs.begin(), expanded.inputs.end(), input);
                    if (it == expanded.inputs.end() || *it != input) {
                        expanded.inputs.insert(it, input);
                    }
                }
                
                {
                    OutcomeType newType = p[1] ? OutcomeType::intermediate : OutcomeType::final;
                    terminalCount += !p[1];
                    auto [it, inserted] = outcomesMap.emplace(std::piecewise_construct,
                                                              std::forward_as_tuple(src, p + 1),
                                                              std::forward_as_tuple(noTransition, newType, dst));
                    if (!inserted) {
                        if (newType == OutcomeType::final) {
                            assert(it->second.type != OutcomeType::final); //if it already exists it must be non final!
                            it->second.payload = dst;
                            terminalCount -= (it->second.type != OutcomeType::intermediate); //avoid double counting!
                            it->second.type = OutcomeType::nonfinal;
                        } else if (it->second.type == OutcomeType::final) {
                            it->second.type = OutcomeType::nonfinal;
                        }
                    }
                }
            }
        }
        
        assert(terminalCount < size_t(std::numeric_limits<LengthType>::max() - 1));
        
        //Step 2: Write out empty outcome and non-intermediate outcomes. Populate outcome indices in map
        
        expanded.outcomes.reserve(terminalCount);
        size_t stateCount = terminalCount;
        expanded.outcomes.push_back({
            emptyOutcome.payload,
            emptyOutcome.type != OutcomeType::intermediate,
            emptyOutcome.type == OutcomeType::final
        });
        for(auto & entry: outcomesMap) {
            if (entry.second.type != OutcomeType::intermediate) {
                entry.second.idx = static_cast<LengthType>(expanded.outcomes.size());
                expanded.outcomes.push_back({
                    entry.second.payload,
                    true,
                    entry.second.type == OutcomeType::final
                });
            } else {
                entry.second.idx = stateCount++;
                assert(stateCount < size_t(std::numeric_limits<LengthType>::max() - 1));
            }
        }
        assert(stateCount - 1 == outcomesMap.size());
        
        //Step 3: Populate transitions table using input and outcome indices
        
        expanded.transitions.resize(stateCount * expanded.inputs.size(), -1);
        
        for(auto [dst, src]: range) {
            
            LengthType currentState = 0;
            for(const Char * p = src; *p; ++p) {
                
                size_t inputIdx;
                {
                    auto it = std::lower_bound(expanded.inputs.begin(), expanded.inputs.end(), *p);
                    assert(it != expanded.inputs.end() && *it == *p);
                    inputIdx = it - expanded.inputs.begin();
                }
                
                auto & nextState = expanded.transitions[currentState * expanded.inputs.size() + inputIdx];
                if (nextState != noTransition) {
                    currentState = nextState;
                    continue;
                }
                
                auto it = outcomesMap.find({src, p + 1});
                assert(it != outcomesMap.end());
                nextState = static_cast<LengthType>(it->second.idx);
                currentState = nextState;
            }
        }
        
        //Step 4: Compact everything into one memory block
        
        m_inputsEnd = expanded.inputs.size() * sizeof(expanded.inputs[0]);
        m_transitionsStart = alignSize(m_inputsEnd, __alignof(expanded.transitions[0]));
        m_transitionsEnd = m_transitionsStart + expanded.transitions.size() * sizeof(expanded.transitions[0]);
        m_outcomesStart = alignSize(m_transitionsEnd, __alignof(expanded.outcomes[0]));
        size_t compactSize = m_outcomesStart + expanded.outcomes.size() * sizeof(expanded.outcomes[0]);
        m_data.resize(compactSize);
        std::copy(expanded.inputs.begin(), expanded.inputs.end(), inputsBegin());
        std::copy(expanded.transitions.begin(), expanded.transitions.end(), transitionsBegin());
        std::copy(expanded.outcomes.begin(), expanded.outcomes.end(), outcomesBegin());
    }
    
    template<class ItF, class ItL>
    requires(std::is_convertible_v<typename std::iterator_traits<ItF>::iterator_category, std::input_iterator_tag> &&
             std::is_convertible_v<std::tuple_element_t<0, typename std::iterator_traits<ItF>::value_type>, PayloadType> &&
             std::is_convertible_v<std::tuple_element_t<1, typename std::iterator_traits<ItF>::value_type>, const Char *>)
    StateMachine(ItF first, ItL last):
        StateMachine(std::ranges::subrange(first, last))
    {}
    
    StateMachine(std::initializer_list<std::pair<PayloadType, const Char *>> init):
        StateMachine(init.begin(), init.end())
    {}
    
    StateMachine() = default;
    
    template<class It>
    struct PrefixMatchResult {
        /**
         End of match
         If !successful always stays at the start of input
         */
        It next;
        /** The payload of the successful match if successful. Undefined otherwise */
        PayloadType payload;
        /** Whether the match was successfull. */
        bool successful;
        /** Whether the answer is definite and won't change with larger input */
        bool definite;
    };
    
    template<class ItF, class ItL>
    requires(std::is_convertible_v<typename std::iterator_traits<ItF>::iterator_category, std::forward_iterator_tag> &&
            std::is_same_v<typename std::iterator_traits<ItF>::value_type, Char> &&
            std::equality_comparable_with<ItF, ItL>)
    auto prefixMatch(ItF first, ItL last) const noexcept -> PrefixMatchResult<ItF> {
        
        LengthType currentState = 0;
        LengthType lastMatchedState = 0;
        auto current = first;
        auto consumed = first;
        while(current != last) {
            
            Char c = *current;
            auto it = std::lower_bound(inputsBegin(), inputsEnd(), c);
            if (it == inputsEnd() || *it != c) {
                if (currentState >= outcomesSize())
                    return {first, {}, false, true};
                auto & outcome = outcomesBegin()[currentState];
                return {current, outcome.payload, outcome.successful, true};
            }
            size_t inputIdx = it - inputsBegin();
            
            auto nextState = transitionFor(inputIdx, currentState);
            if (nextState == noTransition) {
                if (currentState >= outcomesSize())
                    return {first, {}, false, true};
                auto & outcome = outcomesBegin()[currentState];
                return {current, outcome.payload, outcome.successful, true};
            }
            
            if (currentState < outcomesSize()) {
                consumed = current;
                lastMatchedState = currentState;
            }
            currentState = nextState;
            ++current;
        }
        if (currentState >= outcomesSize()) {
            if (lastMatchedState == 0)
                return {first, {}, false, inputsSize() == 0};
            auto & outcome = outcomesBegin()[lastMatchedState];
            return {consumed, outcome.payload, outcome.successful, outcome.final};
        }
        auto & outcome = outcomesBegin()[currentState];
        return {last, outcome.payload, outcome.successful, outcome.final};
        
    }
    
private:
    // Round size up to next multiple of alignment.
    static constexpr auto alignSize(size_t s, size_t alignment) noexcept -> size_t {
        assert(s + alignment > s);
        return (s + alignment - 1) & ~(alignment - 1);
    }
    
    auto inputsBegin() const
        { return reinterpret_cast<const Char *>(m_data.data()); }
    auto inputsBegin()
        { return reinterpret_cast<Char *>(m_data.data()); }
    auto inputsEnd() const
        { return reinterpret_cast<const Char *>(m_data.data() + m_inputsEnd); }
    auto inputsEnd()
        { return reinterpret_cast<Char *>(m_data.data() + m_inputsEnd); }
    
    auto transitionsBegin() const
        { return reinterpret_cast<const LengthType *>(m_data.data() + m_transitionsStart); }
    auto transitionsBegin()
        { return reinterpret_cast<LengthType *>(m_data.data() + m_transitionsStart); }
    
    auto outcomesBegin() const
        { return reinterpret_cast<const Outcome *>(m_data.data() + m_outcomesStart); }
    auto outcomesBegin()
        { return reinterpret_cast<Outcome *>(m_data.data() + m_outcomesStart); }
    
    
    auto inputsSize() const -> LengthType
        { return LengthType(m_inputsEnd / sizeof(Char)); }
    auto transitionFor(LengthType inputIdx, LengthType state) const
        { return transitionsBegin()[state * inputsSize() + inputIdx]; }
    
    auto outcomesSize() const -> LengthType
        { return LengthType((m_data.size() - m_outcomesStart) / sizeof(Outcome)); }
    
private:
    std::vector<uint8_t> m_data;
    size_t m_inputsEnd = 0;
    size_t m_transitionsStart = 0;
    size_t m_transitionsEnd = 0;
    size_t m_outcomesStart = 0;
};

#endif


