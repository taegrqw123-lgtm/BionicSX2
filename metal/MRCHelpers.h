// PORTED FROM: common/MRCHelpers.h — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.2
// STATUS: GREEN — Obj-C manual reference counting, identical on iOS and macOS

#pragma once

// Manual Reference Counting helper.
// On iOS and macOS, Obj-C MRC works identically.
template <typename T>
class MRCOwned
{
public:
    MRCOwned() : m_obj(nil) {}
    MRCOwned(std::nullptr_t) : m_obj(nil) {}
    explicit MRCOwned(T obj) : m_obj(obj) {}
    MRCOwned(const MRCOwned& other) : m_obj([other.m_obj retain]) {}
    MRCOwned(MRCOwned&& other) : m_obj(other.m_obj) { other.m_obj = nil; }
    ~MRCOwned() { [m_obj release]; }

    MRCOwned& operator=(T obj)
    {
        if (m_obj != obj)
        {
            [m_obj release];
            m_obj = [obj retain];
        }
        return *this;
    }

    MRCOwned& operator=(const MRCOwned& other)
    {
        if (this != &other)
            *this = other.m_obj;
        return *this;
    }

    MRCOwned& operator=(MRCOwned&& other)
    {
        if (this != &other)
        {
            [m_obj release];
            m_obj = other.m_obj;
            other.m_obj = nil;
        }
        return *this;
    }

    operator T() const { return m_obj; }
    T operator->() const { return m_obj; }
    T get() const { return m_obj; }
    explicit operator bool() const { return m_obj != nil; }

    T* operator&() { return &m_obj; }
    const T* operator&() const { return &m_obj; }

    void reset(T obj = nil)
    {
        [m_obj release];
        m_obj = [obj retain];
    }

    T release()
    {
        T tmp = m_obj;
        m_obj = nil;
        return tmp;
    }

    T assumeOwnership()
    {
        T tmp = m_obj;
        m_obj = nil;
        return tmp;
    }

private:
    T m_obj;
};
