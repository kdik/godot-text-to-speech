@icon("res://addons/text_to_speech/icon_2d.png")

class_name TextToSpeech2D
extends AudioStreamPlayer2D

func say(text, voice_id = "cmu_us_aew.flitevox.res", speed = 1.0) -> Signal:
	return await TextToSpeechEngine.get_singleton().say(self, text, voice_id, speed)
