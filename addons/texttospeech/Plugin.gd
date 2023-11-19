tool
extends EditorPlugin

const AUTOLOAD_NAME = "TextToSpeechEngine"

func _enter_tree():
    add_autoload_singleton(AUTOLOAD_NAME, "res://addons/texttospeech/TextToSpeechEngine.gd")
    add_custom_type("TextToSpeech", "AudioStreamPlayer", load("res://addons/texttospeech/TextToSpeech.gd"), preload("res://addons/texttospeech/icon.png"))
    add_custom_type("TextToSpeech2D", "AudioStreamPlayer2D", load("res://addons/texttospeech/TextToSpeech2D.gd"), preload("res://addons/texttospeech/icon_2d.png"))
    add_custom_type("TextToSpeech3D", "AudioStreamPlayer3D", load("res://addons/texttospeech/TextToSpeech3D.gd"), preload("res://addons/texttospeech/icon_3d.png"))

func _exit_tree():
    remove_custom_type("TextToSpeech")
    remove_custom_type("TextToSpeech2D")
    remove_custom_type("TextToSpeech3D")
