// PORTED: BionicSX2 iOS — Stub replacement for HwRead.cpp
// All device I/O functions are stubbed; real dispatch lives in PCSX2Stubs.mm

#include "PrecompiledHeader.h"
#include "Hw.h"

template<u8 page>
u8 _hwRead8(u32 addr) { return 0; }
template u8 _hwRead8<0x00>(u32);
template u8 _hwRead8<0x01>(u32);
template u8 _hwRead8<0x02>(u32);
template u8 _hwRead8<0x03>(u32);
template u8 _hwRead8<0x04>(u32);
template u8 _hwRead8<0x05>(u32);
template u8 _hwRead8<0x06>(u32);
template u8 _hwRead8<0x07>(u32);
template u8 _hwRead8<0x08>(u32);
template u8 _hwRead8<0x09>(u32);
template u8 _hwRead8<0x0A>(u32);
template u8 _hwRead8<0x0B>(u32);
template u8 _hwRead8<0x0C>(u32);
template u8 _hwRead8<0x0D>(u32);
template u8 _hwRead8<0x0E>(u32);
template u8 _hwRead8<0x0F>(u32);

template<u8 page>
u16 _hwRead16(u32 addr) { return 0; }
template u16 _hwRead16<0x00>(u32);

template<u8 page>
u32 _hwRead32(u32 addr) { return 0; }
template u32 _hwRead32<0x00>(u32);

template<u8 page>
u64 _hwRead64(u32 addr) { return 0; }
template u64 _hwRead64<0x00>(u32);

template<u8 page>
u128 _hwRead128(u32 addr) { u128 v = {}; return v; }
template u128 _hwRead128<0x00>(u32);

template<u8 page>
void _hwWrite8(u32 addr, u8 val) {}
template void _hwWrite8<0x00>(u32, u8);

template<u8 page>
void _hwWrite16(u32 addr, u16 val) {}
template void _hwWrite16<0x00>(u32, u16);

template<u8 page>
void _hwWrite32(u32 addr, u32 val) {}
template void _hwWrite32<0x00>(u32, u32);

template<u8 page>
void _hwWrite64(u32 addr, u64 val) {}
template void _hwWrite64<0x00>(u32, u64);

template<u8 page>
void _hwWrite128(u32 addr, u128 val) {}
template void _hwWrite128<0x00>(u32, u128);
