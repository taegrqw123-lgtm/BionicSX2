// BionicSX2 iOS — Stub HwRead.cpp with full page instantiations
#include "PrecompiledHeader.h"
#include "MemoryTypes.h"
#include "ps2/HwInternal.h"

template<uint page> mem8_t  hwRead8(u32)  { return 0; }
template<uint page> mem16_t hwRead16(u32) { return 0; }
template<uint page> mem32_t hwRead32(u32) { return 0; }
template<uint page> mem64_t hwRead64(u32) { return 0; }
template<uint page> RETURNS_R128 hwRead128(u32) { r128 v={}; return v; }

#define INSTANTIATE_READ_ALL(name) \
  template mem8_t  name<0u>(u32); template mem8_t  name<1u>(u32); \
  template mem8_t  name<2u>(u32); template mem8_t  name<3u>(u32); \
  template mem8_t  name<4u>(u32); template mem8_t  name<5u>(u32); \
  template mem8_t  name<6u>(u32); template mem8_t  name<7u>(u32); \
  template mem8_t  name<8u>(u32); template mem8_t  name<9u>(u32); \
  template mem8_t  name<10u>(u32); template mem8_t name<11u>(u32); \
  template mem8_t  name<12u>(u32); template mem8_t name<13u>(u32); \
  template mem8_t  name<14u>(u32); template mem8_t name<15u>(u32);

INSTANTIATE_READ_ALL(hwRead8)

#undef INSTANTIATE_READ_ALL
#define INSTANTIATE_READ_ALL(name) \
  template mem16_t name<0u>(u32); template mem16_t name<1u>(u32); \
  template mem16_t name<2u>(u32); template mem16_t name<3u>(u32); \
  template mem16_t name<4u>(u32); template mem16_t name<5u>(u32); \
  template mem16_t name<6u>(u32); template mem16_t name<7u>(u32); \
  template mem16_t name<8u>(u32); template mem16_t name<9u>(u32); \
  template mem16_t name<10u>(u32); template mem16_t name<11u>(u32); \
  template mem16_t name<12u>(u32); template mem16_t name<13u>(u32); \
  template mem16_t name<14u>(u32); template mem16_t name<15u>(u32);

INSTANTIATE_READ_ALL(hwRead16)

#undef INSTANTIATE_READ_ALL
#define INSTANTIATE_READ_ALL(name) \
  template mem32_t name<0u>(u32); template mem32_t name<1u>(u32); \
  template mem32_t name<2u>(u32); template mem32_t name<3u>(u32); \
  template mem32_t name<4u>(u32); template mem32_t name<5u>(u32); \
  template mem32_t name<6u>(u32); template mem32_t name<7u>(u32); \
  template mem32_t name<8u>(u32); template mem32_t name<9u>(u32); \
  template mem32_t name<10u>(u32); template mem32_t name<11u>(u32); \
  template mem32_t name<12u>(u32); template mem32_t name<13u>(u32); \
  template mem32_t name<14u>(u32); template mem32_t name<15u>(u32);

INSTANTIATE_READ_ALL(hwRead32)

#undef INSTANTIATE_READ_ALL
#define INSTANTIATE_READ_ALL(name) \
  template mem64_t name<0u>(u32); template mem64_t name<1u>(u32); \
  template mem64_t name<2u>(u32); template mem64_t name<3u>(u32); \
  template mem64_t name<4u>(u32); template mem64_t name<5u>(u32); \
  template mem64_t name<6u>(u32); template mem64_t name<7u>(u32); \
  template mem64_t name<8u>(u32); template mem64_t name<9u>(u32); \
  template mem64_t name<10u>(u32); template mem64_t name<11u>(u32); \
  template mem64_t name<12u>(u32); template mem64_t name<13u>(u32); \
  template mem64_t name<14u>(u32); template mem64_t name<15u>(u32);

INSTANTIATE_READ_ALL(hwRead64)

#undef INSTANTIATE_READ_ALL
#define INSTANTIATE_READ_ALL(name) \
  template RETURNS_R128 name<0u>(u32); template RETURNS_R128 name<1u>(u32); \
  template RETURNS_R128 name<2u>(u32); template RETURNS_R128 name<3u>(u32); \
  template RETURNS_R128 name<4u>(u32); template RETURNS_R128 name<5u>(u32); \
  template RETURNS_R128 name<6u>(u32); template RETURNS_R128 name<7u>(u32); \
  template RETURNS_R128 name<8u>(u32); template RETURNS_R128 name<9u>(u32); \
  template RETURNS_R128 name<10u>(u32); template RETURNS_R128 name<11u>(u32); \
  template RETURNS_R128 name<12u>(u32); template RETURNS_R128 name<13u>(u32); \
  template RETURNS_R128 name<14u>(u32); template RETURNS_R128 name<15u>(u32);

INSTANTIATE_READ_ALL(hwRead128)
