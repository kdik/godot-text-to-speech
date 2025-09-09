#pragma once
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// Set the voice file path (absolute).
// Call this once before calling flite_synth_to_pcm(). Returns 0 on success.
int flite_set_voice_path(const char *voice_path);

// Synthesize text -> int16 PCM (mono).
// Parameters:
//  - text_utf8: null-terminated UTF-8 text
//  - out_pcm: pointer to malloc'd int16 buffer (caller frees it using free())
//  - out_samples: number of int16 samples (not frames; mono samples)
//  - out_sample_rate: sample rate used (e.g., 22050)
// Return 0 on success, non-zero on failure.
int flite_synth_to_pcm(const char *text_utf8, short **out_pcm, size_t *out_samples, int *out_sample_rate);

#ifdef __cplusplus
}
#endif
