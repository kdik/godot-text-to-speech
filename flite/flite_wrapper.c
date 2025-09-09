#include "flite_wrapper.h"
#include <stdlib.h>
#include <string.h>

// Include the Flite API headers
// Depending on your flite include path this may be <flite.h> or <flite/flite.h>
// Adjust include path in CMake accordingly.
#include <flite.h>

static cst_voice *g_voice = NULL;
static int g_inited = 0;

int flite_set_voice_path(const char *voice_path) {
    if (!g_inited) {
        flite_init();
        g_inited = 1;
    }

    // If a voice is already loaded, free it (flite doesn't provide explicit free voice; reuse pointer)
    // Attempt to load voice from the provided path.
    cst_voice *v = flite_voice_load(voice_path);
    if (!v) {
        return -1;
    }

    g_voice = v;
    return 0;
}

int flite_synth_to_pcm(const char *text_utf8, short **out_pcm, size_t *out_samples, int *out_sample_rate) {
    if (!g_inited) {
        flite_init();
        g_inited = 1;
    }
    if (!g_voice) {
        // No voice loaded
        return -2;
    }
    if (!text_utf8 || !out_pcm || !out_samples || !out_sample_rate) {
        return -3;
    }

    // Synthesize to a cst_wave*
    cst_wave *w = flite_text_to_wave(text_utf8, g_voice);
    if (!w) return -4;

    // Copy samples out
    int ns = w->num_samples;            // number of int16 samples (mono)
    int sr = w->sample_rate;

    // Allocate buffer (caller will free with free())
    short *buf = (short *)malloc(sizeof(short) * (size_t)ns);
    if (!buf) {
        delete_wave(w);
        return -5;
    }

    memcpy(buf, w->samples, sizeof(short) * (size_t)ns);

    *out_pcm = buf;
    *out_samples = (size_t)ns;
    *out_sample_rate = sr;

    delete_wave(w);

    return 0;
}

void flite_cleanup() {
    // Flite doesn't provide an API to free voice pointers across all versions, so we just null it.
    g_voice = NULL;
    // no more cleanup for flite internals here
}
