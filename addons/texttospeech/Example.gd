extends Node2D

func _ready():
    var text = "Text to speech is a really neat thing."
    var speed = 0.9
    yield($TextToSpeech.say(text, TextToSpeechEngine.VOICE_AWB, speed), "completed")
    yield($TextToSpeech.say(text, TextToSpeechEngine.VOICE_AHW, speed), "completed")
    yield($TextToSpeech.say(text, TextToSpeechEngine.VOICE_FEM, speed), "completed")
    yield($TextToSpeech.say(text, TextToSpeechEngine.VOICE_AEW, speed), "completed")
    yield($TextToSpeech.say(text, TextToSpeechEngine.VOICE_SLT, speed), "completed")
    yield($TextToSpeech.say(text, TextToSpeechEngine.VOICE_EEY, speed), "completed")
    yield($TextToSpeech.say(text, TextToSpeechEngine.VOICE_CLB, speed), "completed")
