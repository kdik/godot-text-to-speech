class_name TextToSpeechEngine
extends Node

var tts: TextToSpeech = TextToSpeech.new()
var voice_manager = VoiceManager.new()
var current_voice_path

func load_voice(voice_path):
	voice_manager.ensure_voices_installed()
	await voice_manager.wait_for_voice(voice_path)
	tts.set_voice_path(voice_path)

func say(player, text: String, voice: String, speed: float) -> void:
	var voice_path = voice_manager.get_voice_path(voice)
	if current_voice_path != voice_path:
		current_voice_path = voice_path
		await load_voice(voice_path)

	var pcm: PackedByteArray = tts.speak_to_buffer(text)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.stereo = false
	wav.mix_rate = tts.get_sample_rate() * speed
	wav.data = pcm

	player.stream = wav
	await Engine.get_main_loop().process_frame
	player.play()
	
	var samples := pcm.size() / 2  # 16-bit samples → 2 bytes
	var duration := float(samples) / wav.mix_rate

	await Engine.get_main_loop().create_timer(duration).timeout
