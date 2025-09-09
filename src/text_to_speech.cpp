#include "text_to_speech.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <flite.h>

using namespace godot;

// Forward declarations of Flite language + lexicon init
extern "C" {
    void usenglish_init(cst_voice *v);
    cst_lexicon *cmulex_init(void);
}

TextToSpeech::TextToSpeech() {
    UtilityFunctions::print("TTS constructor");

    flite_init();
    flite_add_lang("eng", usenglish_init, cmulex_init);
    flite_add_lang("usenglish", usenglish_init, cmulex_init);

    current_voice = nullptr;
}

TextToSpeech::~TextToSpeech() {
    UtilityFunctions::print("TTS destructor");
}

Error TextToSpeech::set_voice_path(const String &p_path) {
    std::string path = p_path.utf8().get_data();

    cst_voice *v = flite_voice_load(path.c_str());
    if (!v) {
        UtilityFunctions::printerr("Failed to load voice: ", path.c_str());
        return ERR_CANT_OPEN;
    }

    current_voice = v;
    UtilityFunctions::print("Voice loaded: ", path.c_str());
    return OK;
}

PackedByteArray TextToSpeech::speak_to_buffer(const String &p_text) {
    PackedByteArray buffer;

    if (!current_voice) {
        UtilityFunctions::printerr("No voice set, call set_voice_path() first");
        return buffer;
    }

    std::string text = p_text.utf8().get_data();
    cst_wave *wave = flite_text_to_wave(text.c_str(), current_voice);
    if (!wave) {
        UtilityFunctions::printerr("Flite synthesis failed");
        return buffer;
    }

    buffer.resize(wave->num_samples * 2);
    for (int i = 0; i < wave->num_samples; i++) {
        int16_t sample = wave->samples[i];
        buffer.set(i * 2, sample & 0xff);
        buffer.set(i * 2 + 1, (sample >> 8) & 0xff);
    }

    sample_rate = wave->sample_rate;
    delete_wave(wave);

    // 🔔 Notify GDScript that synthesis finished
    emit_completed();

    return buffer;
}

int TextToSpeech::get_sample_rate() const {
    return sample_rate;
}

void TextToSpeech::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_voice_path", "path"), &TextToSpeech::set_voice_path);
    ClassDB::bind_method(D_METHOD("speak_to_buffer", "text"), &TextToSpeech::speak_to_buffer);
    ClassDB::bind_method(D_METHOD("get_sample_rate"), &TextToSpeech::get_sample_rate);

    ADD_SIGNAL(MethodInfo("completed"));
}

void TextToSpeech::emit_completed() {
    emit_signal("completed");
}
