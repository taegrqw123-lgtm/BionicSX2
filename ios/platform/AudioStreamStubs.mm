// Stubs for AudioStream factory methods needed at link time
// These are required by AudioStream.cpp but not used on iOS (using cubeb or AVAudioEngine)

#include "PrecompiledHeader.h"
#include "Host/AudioStream.h"
#include "common/Error.h"
#include <memory>

std::unique_ptr<AudioStream> AudioStream::CreateStream(AudioBackend, u32,
    const AudioStreamParameters&, const char*, const char*, bool, Error*)
{
    return nullptr;
}

std::unique_ptr<AudioStream> AudioStream::CreateCubebAudioStream(u32,
    const AudioStreamParameters&, const char*, const char*, bool, Error*)
{
    return nullptr;
}

std::unique_ptr<AudioStream> AudioStream::CreateSDLAudioStream(u32,
    const AudioStreamParameters&, bool, Error*)
{
    return nullptr;
}
