@icon("res://addons/text_to_speech/icon_1d.png")

class_name TextToSpeech1D
extends AudioStreamPlayer

var text_to_speech_engine : TextToSpeechEngine

func _ready() -> void:
	text_to_speech_engine = TextToSpeechEngine.new()

func say(text, voice = "cmu_us_aew", speed = 1.0) -> void:
	await text_to_speech_engine.say(self, text, voice, speed)
