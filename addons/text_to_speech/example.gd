extends Node2D

func _ready():
	await $TextToSpeech1.say("Text to speech is a really neat thing.")
	await $TextToSpeech2.say("We can also speak in different voices.", "cmu_us_slt")
	await $TextToSpeech1.say("And slower too.", "cmu_us_awb", 0.75)
	$TextToSpeech1.say("And we can both speak at the same time.", "cmu_us_fem")
	$TextToSpeech2.say("And we can both speak at the same time.", "cmu_us_eey")
