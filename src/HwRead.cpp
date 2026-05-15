// BionicSX2 iOS — Stub HwRead.cpp
// Provides explicit template instantiations for all hwRead* pages
#include "PrecompiledHeader.h"
#include "MemoryTypes.h"
#include "ps2/HwInternal.h"

template<uint page> mem32_t hwRead32(u32 mem) { return 0; }
template<uint page> mem64_t hwRead64(u32 mem) { return 0; }
template<uint page> RETURNS_R128 hwRead128(u32 mem) { r128 v = {}; return v; }

template mem32_t hwRead32<0x00>(u32);
template mem32_t hwRead32<0x01>(u32);
template mem32_t hwRead32<0x02>(u32);
template mem32_t hwRead32<0x03>(u32);
template mem32_t hwRead32<0x04>(u32);
template mem32_t hwRead32<0x05>(u32);
template mem32_t hwRead32<0x06>(u32);
template mem32_t hwRead32<0x07>(u32);
template mem32_t hwRead32<0x08>(u32);
template mem32_t hwRead32<0x09>(u32);
template mem32_t hwRead32<0x0A>(u32);
template mem32_t hwRead32<0x0B>(u32);
template mem32_t hwRead32<0x0C>(u32);
template mem32_t hwRead32<0x0D>(u32);
template mem32_t hwRead32<0x0E>(u32);
template mem32_t hwRead32<0x0F>(u32);

template mem64_t hwRead64<0x00>(u32);

template RETURNS_R128 hwRead128<0x00>(u32);
template RETURNS_R128 hwRead128<0x01>(u32);
template RETURNS_R128 hwRead128<0x02>(u32);
template RETURNS_R128 hwRead128<0x03>(u32);
template RETURNS_R128 hwRead128<0x04>(u32);
template RETURNS_R128 hwRead128<0x05>(u32);
template RETURNS_R128 hwRead128<0x06>(u32);
template RETURNS_R128 hwRead128<0x07>(u32);
template RETURNS_R128 hwRead128<0x08>(u32);
template RETURNS_R128 hwRead128<0x09>(u32);
template RETURNS_R128 hwRead128<0x0A>(u32);
template RETURNS_R128 hwRead128<0x0B>(u32);
template RETURNS_R128 hwRead128<0x0C>(u32);
template RETURNS_R128 hwRead128<0x0D>(u32);
template RETURNS_R128 hwRead128<0x0E>(u32);
template RETURNS_R128 hwRead128<0x0F>(u32);
