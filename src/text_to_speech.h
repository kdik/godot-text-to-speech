#ifndef TEXT_TO_SPEECH_H
#define TEXT_TO_SPEECH_H

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>
#include <godot_cpp/core/error_macros.hpp>
#include <flite.h>

using namespace godot;

class TextToSpeech : public RefCounted {
    GDCLASS(TextToSpeech, RefCounted)

private:
    cst_voice *current_voice = nullptr;
    int sample_rate = 16000;

protected:
    static void _bind_methods();

public:
    TextToSpeech();
    ~TextToSpeech();

    // Load a .flitevox file
    Error set_voice_path(const String &path);

    // Convert text into raw audio buffer
    PackedByteArray speak_to_buffer(const String &text);

    // Get sample rate of last synthesis
    int get_sample_rate() const;
};

#endif // TEXT_TO_SPEECH_H
