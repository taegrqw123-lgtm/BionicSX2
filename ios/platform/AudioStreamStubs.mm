// Stubs for AudioStream methods needed at link time
#include "PrecompiledHeader.h"
#include "Host/AudioStream.h"
#include "Host/AudioStreamTypes.h"
#include "common/Error.h"
#include <memory>
#include <string>
#include <vector>

// Factory methods
std::unique_ptr<AudioStream> AudioStream::CreateStream(AudioBackend, u32,
    const AudioStreamParameters&, const char*, const char*, bool, Error*)
{ return nullptr; }

std::unique_ptr<AudioStream> AudioStream::CreateCubebAudioStream(u32,
    const AudioStreamParameters&, const char*, const char*, bool, Error*)
{ return nullptr; }

std::unique_ptr<AudioStream> AudioStream::CreateSDLAudioStream(u32,
    const AudioStreamParameters&, bool, Error*)
{ return nullptr; }

std::unique_ptr<AudioStream> AudioStream::CreateNullStream(u32, u32)
{ return nullptr; }

// Member functions
void AudioStream::EmptyBuffer() {}
void AudioStream::SetNominalRate(float) {}
void AudioStream::SetOutputVolume(u32) {}
void AudioStream::SetStretchEnabled(bool) {}
void AudioStream::WriteChunk(const float*) {}
std::string AudioStream::GetBackendName(AudioBackend) { return "Null"; }
AudioBackend AudioStream::ParseBackendName(const char*) { return AudioBackend::Null; }

// Parameters
bool AudioStreamParameters::operator==(const AudioStreamParameters&) const { return true; }
bool AudioStreamParameters::operator!=(const AudioStreamParameters&) const { return false; }
void AudioStreamParameters::LoadSave(SettingsWrapper&, const char*) {}

// DeviceInfo
AudioStream::DeviceInfo::DeviceInfo(std::string n, std::string dn, u32 l)
    : name(std::move(n)), display_name(std::move(dn)), minimum_latency_frames(l) {}
AudioStream::DeviceInfo::~DeviceInfo() {}

// Static helpers
std::vector<std::pair<std::string, std::string>> AudioStream::GetCubebDriverNames()
{ return {}; }
std::vector<AudioStream::DeviceInfo> AudioStream::GetCubebOutputDevices(const char*)
{ return {}; }
