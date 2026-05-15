// BionicSX2 iOS — Stub HwWrite.cpp
// Provides explicit template instantiations for all hwWrite* pages
#include "PrecompiledHeader.h"
#include "ps2/HwInternal.h"

template<uint page> void hwWrite8(u32 mem, mem8_t val) {}
template<uint page> void hwWrite16(u32 mem, mem16_t val) {}
template<uint page> void hwWrite32(u32 mem, mem32_t val) {}
template<uint page> void hwWrite64(u32 mem, mem64_t val) {}
template<uint page> void TAKES_R128 hwWrite128(u32 mem, r128 val) {}

template void hwWrite8<0x00>(u32, mem8_t);
template void hwWrite16<0x00>(u32, mem16_t);
template void hwWrite32<0x00>(u32, mem32_t);
template void hwWrite64<0x00>(u32, mem64_t);
template void TAKES_R128 hwWrite128<0x00>(u32, r128);
template void TAKES_R128 hwWrite128<0x01>(u32, r128);
template void TAKES_R128 hwWrite128<0x02>(u32, r128);
template void TAKES_R128 hwWrite128<0x03>(u32, r128);
template void TAKES_R128 hwWrite128<0x04>(u32, r128);
template void TAKES_R128 hwWrite128<0x05>(u32, r128);
template void TAKES_R128 hwWrite128<0x06>(u32, r128);
template void TAKES_R128 hwWrite128<0x07>(u32, r128);
template void TAKES_R128 hwWrite128<0x08>(u32, r128);
template void TAKES_R128 hwWrite128<0x09>(u32, r128);
template void TAKES_R128 hwWrite128<0x0A>(u32, r128);
template void TAKES_R128 hwWrite128<0x0B>(u32, r128);
template void TAKES_R128 hwWrite128<0x0C>(u32, r128);
template void TAKES_R128 hwWrite128<0x0D>(u32, r128);
template void TAKES_R128 hwWrite128<0x0E>(u32, r128);
template void TAKES_R128 hwWrite128<0x0F>(u32, r128);
