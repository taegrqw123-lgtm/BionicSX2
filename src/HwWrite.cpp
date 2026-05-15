// BionicSX2 iOS — Stub HwWrite.cpp with full page instantiations
#include "PrecompiledHeader.h"
#include "MemoryTypes.h"
#include "ps2/HwInternal.h"

template<uint page> void hwWrite8(u32, mem8_t) {}
template<uint page> void hwWrite16(u32, mem16_t) {}
template<uint page> void hwWrite32(u32, mem32_t) {}
template<uint page> void hwWrite64(u32, mem64_t) {}
template<uint page> void TAKES_R128 hwWrite128(u32, r128) {}

#define INST_P8(name) template void name<0u>(u32, mem8_t); template void name<1u>(u32, mem8_t); \
  template void name<2u>(u32, mem8_t); template void name<3u>(u32, mem8_t); \
  template void name<4u>(u32, mem8_t); template void name<5u>(u32, mem8_t); \
  template void name<6u>(u32, mem8_t); template void name<7u>(u32, mem8_t); \
  template void name<8u>(u32, mem8_t); template void name<9u>(u32, mem8_t); \
  template void name<10u>(u32, mem8_t); template void name<11u>(u32, mem8_t); \
  template void name<12u>(u32, mem8_t); template void name<13u>(u32, mem8_t); \
  template void name<14u>(u32, mem8_t); template void name<15u>(u32, mem8_t);

#define INST_P16(name) template void name<0u>(u32, mem16_t); template void name<1u>(u32, mem16_t); \
  template void name<2u>(u32, mem16_t); template void name<3u>(u32, mem16_t); \
  template void name<4u>(u32, mem16_t); template void name<5u>(u32, mem16_t); \
  template void name<6u>(u32, mem16_t); template void name<7u>(u32, mem16_t); \
  template void name<8u>(u32, mem16_t); template void name<9u>(u32, mem16_t); \
  template void name<10u>(u32, mem16_t); template void name<11u>(u32, mem16_t); \
  template void name<12u>(u32, mem16_t); template void name<13u>(u32, mem16_t); \
  template void name<14u>(u32, mem16_t); template void name<15u>(u32, mem16_t);

#define INST_P32(name) template void name<0u>(u32, mem32_t); template void name<1u>(u32, mem32_t); \
  template void name<2u>(u32, mem32_t); template void name<3u>(u32, mem32_t); \
  template void name<4u>(u32, mem32_t); template void name<5u>(u32, mem32_t); \
  template void name<6u>(u32, mem32_t); template void name<7u>(u32, mem32_t); \
  template void name<8u>(u32, mem32_t); template void name<9u>(u32, mem32_t); \
  template void name<10u>(u32, mem32_t); template void name<11u>(u32, mem32_t); \
  template void name<12u>(u32, mem32_t); template void name<13u>(u32, mem32_t); \
  template void name<14u>(u32, mem32_t); template void name<15u>(u32, mem32_t);

#define INST_P64(name) template void name<0u>(u32, mem64_t); template void name<1u>(u32, mem64_t); \
  template void name<2u>(u32, mem64_t); template void name<3u>(u32, mem64_t); \
  template void name<4u>(u32, mem64_t); template void name<5u>(u32, mem64_t); \
  template void name<6u>(u32, mem64_t); template void name<7u>(u32, mem64_t); \
  template void name<8u>(u32, mem64_t); template void name<9u>(u32, mem64_t); \
  template void name<10u>(u32, mem64_t); template void name<11u>(u32, mem64_t); \
  template void name<12u>(u32, mem64_t); template void name<13u>(u32, mem64_t); \
  template void name<14u>(u32, mem64_t); template void name<15u>(u32, mem64_t);

#define INST_P128(name) template void TAKES_R128 name<0u>(u32, r128); \
  template void TAKES_R128 name<1u>(u32, r128); template void TAKES_R128 name<2u>(u32, r128); \
  template void TAKES_R128 name<3u>(u32, r128); template void TAKES_R128 name<4u>(u32, r128); \
  template void TAKES_R128 name<5u>(u32, r128); template void TAKES_R128 name<6u>(u32, r128); \
  template void TAKES_R128 name<7u>(u32, r128); template void TAKES_R128 name<8u>(u32, r128); \
  template void TAKES_R128 name<9u>(u32, r128); template void TAKES_R128 name<10u>(u32, r128); \
  template void TAKES_R128 name<11u>(u32, r128); template void TAKES_R128 name<12u>(u32, r128); \
  template void TAKES_R128 name<13u>(u32, r128); template void TAKES_R128 name<14u>(u32, r128); \
  template void TAKES_R128 name<15u>(u32, r128);

INST_P8(hwWrite8)
INST_P16(hwWrite16)
INST_P32(hwWrite32)
INST_P64(hwWrite64)
INST_P128(hwWrite128)
