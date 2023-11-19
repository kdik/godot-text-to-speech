tool
extends AudioStreamPlayer3D
class_name TextToSpeech3D

func say(text, voice_id = TextToSpeechEngine.VOICE_AWB, speed = 1.0):
    yield(TextToSpeechEngine.say(self, text, voice_id, speed), "completed")
