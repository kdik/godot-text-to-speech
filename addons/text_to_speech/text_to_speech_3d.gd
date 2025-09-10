@icon("res://addons/text_to_speech/icon_3d.png")

class_name TextToSpeech3D
extends AudioStreamPlayer3D

var text_to_speech_engine : TextToSpeechEngine

func _ready() -> void:
	text_to_speech_engine = TextToSpeechEngine.new()

func say(text, voice = "cmu_us_aew", speed = 1.0) -> void:
	await text_to_speech_engine.say(self, text, voice, speed)
