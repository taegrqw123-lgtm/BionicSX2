// PORTED FROM: pcsx2 — BionicSX2 iOS Port
// STUB: Only provides MakeGSDeviceMTL and GetMetalAdapterList declarations

#pragma once
#include "GS/GS.h"
#include <string>
#include <vector>

class GSDevice;
GSDevice* MakeGSDeviceMTL();
std::vector<GSAdapterInfo> GetMetalAdapterList();
