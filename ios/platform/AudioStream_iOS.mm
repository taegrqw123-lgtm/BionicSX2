// PORTED FROM: pcsx2/Host/CubebAudioStream.cpp — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 9.2, 9.3
// STATUS: NEW — AVAudioEngine-based audio for iOS

// Audit Sec 9.2: cubeb has native iOS AudioUnit backend but we provide an
// AVAudioEngine implementation as the primary iOS audio path.
// Audit Sec 9.3: 5ms IOBufferDuration for low latency, 48000 Hz sample rate.

#include "PrecompiledHeader.h"
#import <AVFoundation/AVFoundation.h>
#include "Host/AudioStream.h"
#include "Host/AudioStreamTypes.h"
#include "common/Console.h"
#include <mutex>
#include <vector>

static AVAudioEngine* s_audioEngine = nil;
static AVAudioPlayerNode* s_audioNode = nil;
static AVAudioFormat* s_audioFormat = nil;
static std::mutex s_audioMutex;
static bool s_initialized = false;
static constexpr uint32_t SAMPLE_RATE = 48000;
static constexpr uint32_t CHUNK_SIZE = 64;      // Audit Sec 9.3
static constexpr uint32_t RING_BUFFER_SIZE = 2048; // Audit Sec 9.3: safe mobile latency

void iOSConfigureAudioSession()
{
    NSError* error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];

    // Audit Sec 9.2: Use Playback category for game audio
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionMixWithOthers
                   error:&error];
    if (error) {
        NSLog(@"[BionicSX2] AVAudioSession category error: %@", error);
    }

    // Audit Sec 9.3: 5ms IOBufferDuration for low latency
    [session setPreferredIOBufferDuration:0.005 error:&error];
    if (error) {
        NSLog(@"[BionicSX2] AVAudioSession buffer duration error: %@", error);
    }

    [session setPreferredSampleRate:SAMPLE_RATE error:&error];
    if (error) {
        NSLog(@"[BionicSX2] AVAudioSession sample rate error: %@", error);
    }

    [session setActive:YES error:&error];
    if (error) {
        NSLog(@"[BionicSX2] AVAudioSession activate error: %@", error);
    }

    NSLog(@"[BionicSX2] AVAudioSession configured: %f Hz", session.sampleRate);
}

bool iOSAudioInit()
{
    std::lock_guard<std::mutex> lock(s_audioMutex);
    if (s_initialized)
        return true;

    iOSConfigureAudioSession();

    s_audioEngine = [[AVAudioEngine alloc] init];
    s_audioNode = [[AVAudioPlayerNode alloc] init];
    [s_audioEngine attachNode:s_audioNode];

    // AUDIT Sec 9.3: Stereo PCM 44100Hz (using 44100 as PS2 native rate through resampler)
    AVAudioFormat* format = [[AVAudioFormat alloc]
        initWithCommonFormat:AVAudioPCMFormatFloat32
                  sampleRate:SAMPLE_RATE
                    channels:2
                 interleaved:NO];
    s_audioFormat = format;

    [s_audioEngine connect:s_audioNode to:s_audioEngine.mainMixerNode format:format];

    NSError* error = nil;
    if (![s_audioEngine startAndReturnError:&error]) {
        NSLog(@"[BionicSX2] AVAudioEngine start failed: %@", error);
        return false;
    }

    [s_audioNode play];
    s_initialized = true;
    NSLog(@"[BionicSX2] AVAudioEngine initialized at %d Hz", SAMPLE_RATE);
    return true;
}

void iOSAudioShutdown()
{
    std::lock_guard<std::mutex> lock(s_audioMutex);
    if (!s_initialized)
        return;

    [s_audioNode stop];
    [s_audioEngine stop];
    [s_audioEngine detachNode:s_audioNode];

    s_audioNode = nil;
    s_audioEngine = nil;
    s_audioFormat = nil;

    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];

    s_initialized = false;
    NSLog(@"[BionicSX2] AVAudioEngine shutdown");
}

// SndOutModule interface matching SPU2::CreateOutputStream() (Audit Sec 2.5)
// This is called by the SPU2 subsystem via the AudioStream abstraction.

class iOSAudioStream : public AudioStream
{
public:
    iOSAudioStream(u32 sample_rate, u32 channels, u32 buffer_size)
        : AudioStream(sample_rate, channels, buffer_size) {}

    bool Init() override
    {
        return iOSAudioInit();
    }

    void Start() override
    {
        std::lock_guard<std::mutex> lock(s_audioMutex);
        if (s_audioNode)
            [s_audioNode play];
    }

    void Stop() override
    {
        std::lock_guard<std::mutex> lock(s_audioMutex);
        if (s_audioNode)
            [s_audioNode pause];
    }

    bool Write(const float* samples, uint32_t num_samples) override
    {
        std::lock_guard<std::mutex> lock(s_audioMutex);
        if (!s_audioNode || !s_audioFormat)
            return false;

        AVAudioPCMBuffer* buffer = [[AVAudioPCMBuffer alloc]
            initWithPCMFormat:s_audioFormat
                frameCapacity:num_samples / 2]; // Stereo
        buffer.frameLength = num_samples / 2;

        // Interleave stereo samples
        for (uint32_t i = 0; i < num_samples / 2; i++) {
            buffer.floatChannelData[0][i] = samples[i * 2];
            buffer.floatChannelData[1][i] = samples[i * 2 + 1];
        }

        [s_audioNode scheduleBuffer:buffer completionHandler:nil];
        return true;
    }

    void Close() override
    {
        iOSAudioShutdown();
    }
};

// Factory function — called by SPU2::CreateOutputStream() (Audit Sec 2.5)
AudioStream* AudioStream::CreateAudioStream(u32 sample_rate, u32 channels, u32 buffer_size)
{
    return new iOSAudioStream(sample_rate, channels, buffer_size);
}

// Handle AVAudioSession interruptions (phone calls, background)
// Must be called from the app delegate
void iOSAudioHandleInterruption(NSNotification* notification)
{
    NSDictionary* userInfo = [notification userInfo];
    NSInteger type = [userInfo[AVAudioSessionInterruptionTypeKey] integerValue];

    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"[BionicSX2] Audio interrupted");
        std::lock_guard<std::mutex> lock(s_audioMutex);
        if (s_audioNode)
            [s_audioNode pause];
    } else if (type == AVAudioSessionInterruptionTypeEnded) {
        NSLog(@"[BionicSX2] Audio interruption ended");
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        std::lock_guard<std::mutex> lock(s_audioMutex);
        if (s_audioNode)
            [s_audioNode play];
    }
}
