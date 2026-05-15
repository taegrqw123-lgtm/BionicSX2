// PORTED FROM: PCSX2 macOS Host callbacks — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 0-F (Category 7), Section 13.7
// STATUS: NEW — All Host:: callbacks stubbed for iOS initial bringup

#import <Foundation/Foundation.h>
#include "PrecompiledHeader.h"
#include "Host.h"
#include "common/ProgressCallback.h"
#include "common/SettingsInterface.h"
#include <mutex>
#include <string>
#include <string_view>
#include <vector>
#include <functional>
#include <optional>

// ── Translation stubs ──
const char* Host::TranslateToCString(const std::string_view, const std::string_view msg) {
    static std::string s;
    s = msg;
    return s.c_str();
}
std::string_view Host::TranslateToStringView(const std::string_view, const std::string_view msg) { return msg; }
std::string Host::TranslateToString(const std::string_view, const std::string_view msg) { return std::string(msg); }
std::string Host::TranslatePluralToString(const char*, const char* msg, const char*, int) { return msg; }
void Host::ClearTranslationCache() {}

// ── OSD stubs ──
void Host::AddOSDMessage(std::string, float) {}
void Host::AddKeyedOSDMessage(std::string, std::string, float) {}
void Host::AddIconOSDMessage(std::string, const char*, const std::string_view, float) {}
void Host::RemoveKeyedOSDMessage(std::string) {}
void Host::ClearOSDMessages() {}

// ── Error/Info reporting ──
void Host::ReportInfoAsync(const std::string_view, const std::string_view) {}
void Host::ReportFormattedInfoAsync(const std::string_view, const char*, ...) {}
void Host::ReportErrorAsync(const std::string_view, const std::string_view) {}
void Host::ReportFormattedErrorAsync(const std::string_view, const char*, ...) {}

// ── Mode queries ──
bool Host::InBatchMode() { return false; }
bool Host::InNoGUIMode() { return false; }

// ── Utility ──
void Host::OpenURL(const std::string_view) {}
bool Host::CopyTextToClipboard(const std::string_view) { return false; }
bool Host::RequestResetSettings(bool, bool, bool, bool, bool) { return false; }
void Host::RequestResizeHostDisplay(s32, s32) {}
void Host::RunOnCPUThread(std::function<void()> fn, bool block) { if (block) fn(); else fn(); }
void Host::RunOnGSThread(std::function<void()> fn) { fn(); }
void Host::RefreshGameListAsync(bool) {}
void Host::CancelGameListRefresh() {}
void Host::RequestVMShutdown(bool, bool, bool) {}
std::string Host::GetHTTPUserAgent() { return "BionicSX2/0.1.0"; }

// ── Base settings ──
std::string Host::GetBaseStringSettingValue(const char*, const char*, const char* def) { return def ? def : ""; }
SmallString Host::GetBaseSmallStringSettingValue(const char*, const char*, const char* def) { return SmallString(def ? def : ""); }
TinyString Host::GetBaseTinyStringSettingValue(const char*, const char*, const char* def) { return TinyString(def ? def : ""); }
bool Host::GetBaseBoolSettingValue(const char*, const char*, bool def) { return def; }
int Host::GetBaseIntSettingValue(const char*, const char*, int def) { return def; }
uint Host::GetBaseUIntSettingValue(const char*, const char*, uint def) { return def; }
float Host::GetBaseFloatSettingValue(const char*, const char*, float def) { return def; }
double Host::GetBaseDoubleSettingValue(const char*, const char*, double def) { return def; }
std::vector<std::string> Host::GetBaseStringListSetting(const char*, const char*) { return {}; }
void Host::SetBaseBoolSettingValue(const char*, const char*, bool) {}
void Host::SetBaseIntSettingValue(const char*, const char*, int) {}
void Host::SetBaseUIntSettingValue(const char*, const char*, uint) {}
void Host::SetBaseFloatSettingValue(const char*, const char*, float) {}
void Host::SetBaseStringSettingValue(const char*, const char*, const char*) {}
void Host::SetBaseStringListSettingValue(const char*, const char*, const std::vector<std::string>&) {}
bool Host::AddBaseValueToStringList(const char*, const char*, const char*) { return false; }
bool Host::RemoveBaseValueFromStringList(const char*, const char*, const char*) { return false; }
bool Host::ContainsBaseSettingValue(const char*, const char*) { return false; }
void Host::RemoveBaseSettingValue(const char*, const char*) {}
void Host::CommitBaseSettingChanges() {}

// ── Layer-aware settings ──
std::string Host::GetStringSettingValue(const char*, const char*, const char* def) { return def ? def : ""; }
SmallString Host::GetSmallStringSettingValue(const char*, const char*, const char* def) { return SmallString(def ? def : ""); }
TinyString Host::GetTinyStringSettingValue(const char*, const char*, const char* def) { return TinyString(def ? def : ""); }
bool Host::GetBoolSettingValue(const char*, const char*, bool def) { return def; }
int Host::GetIntSettingValue(const char*, const char*, int def) { return def; }
uint Host::GetUIntSettingValue(const char*, const char*, uint def) { return def; }
float Host::GetFloatSettingValue(const char*, const char*, float def) { return def; }
double Host::GetDoubleSettingValue(const char*, const char*, double def) { return def; }
std::vector<std::string> Host::GetStringListSetting(const char*, const char*) { return {}; }

// ── Settings interface ──
static std::mutex s_settings_mutex;
std::unique_lock<std::mutex> Host::GetSettingsLock() { return std::unique_lock<std::mutex>(s_settings_mutex); }
std::unique_lock<std::mutex> Host::GetSecretsSettingsLock() { return std::unique_lock<std::mutex>(s_settings_mutex); }
SettingsInterface* Host::GetSettingsInterface() { return nullptr; }
void Host::SetDefaultUISettings(SettingsInterface&) {}
std::unique_ptr<ProgressCallback> Host::CreateHostProgressCallback() { return nullptr; }
int Host::LocaleSensitiveCompare(std::string_view a, std::string_view b) { return a.compare(b); }

// ── Internal ──
SettingsInterface* Host::Internal::GetBaseSettingsLayer() { return nullptr; }
SettingsInterface* Host::Internal::GetSecretsSettingsLayer() { return nullptr; }
SettingsInterface* Host::Internal::GetGameSettingsLayer() { return nullptr; }
SettingsInterface* Host::Internal::GetInputSettingsLayer() { return nullptr; }
void Host::Internal::SetBaseSettingsLayer(SettingsInterface*) {}
void Host::Internal::SetSecretsSettingsLayer(SettingsInterface*) {}
void Host::Internal::SetGameSettingsLayer(SettingsInterface*, std::unique_lock<std::mutex>&) {}
void Host::Internal::SetInputSettingsLayer(SettingsInterface*, std::unique_lock<std::mutex>&) {}
s32 Host::Internal::GetTranslatedStringImpl(const std::string_view, const std::string_view, char*, size_t) { return 0; }
