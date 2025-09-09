#include <godot_cpp/godot.hpp>
#include <godot_cpp/core/class_db.hpp>
#include "text_to_speech.h"

using namespace godot;

extern "C" {

GDExtensionBool GDE_EXPORT gdextension_text_to_speech_init(
        GDExtensionInterfaceGetProcAddress p_get_proc_address,
        GDExtensionClassLibraryPtr p_library,
        GDExtensionInitialization *r_initialization) {
    
    GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

    init_obj.register_initializer([](ModuleInitializationLevel p_level) {
        if (p_level == MODULE_INITIALIZATION_LEVEL_SCENE) {
            ClassDB::register_class<TextToSpeech>();
        }
    });

    init_obj.register_terminator([](ModuleInitializationLevel p_level) {
        if (p_level == MODULE_INITIALIZATION_LEVEL_SCENE) {
            // Cleanup if needed
        }
    });

    init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}

} // extern "C"
