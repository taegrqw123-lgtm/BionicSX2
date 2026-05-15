// Provides definitions for CBreakPoints static members and other breakpoint globals
#include "PrecompiledHeader.h"
#include "DebugTools/Breakpoints.h"

bool CBreakPoints::breakpointTriggered_ = false;
BreakPointCpu CBreakPoints::breakpointTriggeredCpu_ = BreakPointCpu(0);
std::vector<MemCheck> CBreakPoints::memChecks_;
