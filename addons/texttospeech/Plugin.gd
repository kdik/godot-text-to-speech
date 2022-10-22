tool
extends EditorPlugin


func _enter_tree():
    add_custom_type("TextToSpeech", "AudioStreamPlayer", preload("res://addons/texttospeech/TextToSpeech.gd"), preload("res://addons/texttospeech/icon.png"))
    add_custom_type("TextToSpeech2D", "AudioStreamPlayer2D", preload("res://addons/texttospeech/TextToSpeech2D.gd"), preload("res://addons/texttospeech/icon_2d.png"))
    add_custom_type("TextToSpeech3D", "AudioStreamPlayer3D", preload("res://addons/texttospeech/TextToSpeech3D.gd"), preload("res://addons/texttospeech/icon_3d.png"))

func _exit_tree():
    remove_custom_type("TextToSpeech")
    remove_custom_type("TextToSpeech2D")
    remove_custom_type("TextToSpeech3D")
