extends Node2D

func _ready():
    var text = "Text to speech is a really neat thing."
    var speed = 0.9
    yield($TextToSpeech.say(text, TextToSpeech.VOICE_AWB, speed), "completed")
    yield($TextToSpeech.say(text, TextToSpeech.VOICE_KAL, speed), "completed")
    yield($TextToSpeech.say(text, TextToSpeech.VOICE_RMS, speed), "completed")
    yield($TextToSpeech.say(text, TextToSpeech.VOICE_SLT, speed), "completed")

