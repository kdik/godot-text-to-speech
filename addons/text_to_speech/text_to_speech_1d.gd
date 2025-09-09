@icon("res://addons/text_to_speech/icon.png")

class_name TextToSpeech1D
extends AudioStreamPlayer

func say(text, voice_id = "cmu_us_aew.flitevox.res", speed = 1.0) -> Signal:
	return await TextToSpeechEngine.get_singleton().say(self, text, voice_id, speed)
