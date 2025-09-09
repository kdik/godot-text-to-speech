class_name TextToSpeechEngine
extends Node

signal completed

var tts: TextToSpeech = TextToSpeech.new()
var voice_manager = VoiceManager.new()

static var _instance: TextToSpeechEngine

static func get_singleton() -> TextToSpeechEngine:
	if _instance == null:
		_instance = TextToSpeechEngine.new()
		Engine.get_main_loop().root.call_deferred("add_child", _instance)
	return _instance

func _ready() -> void:
	voice_manager.ensure_voices_installed()
	
func _wait_for_voice(file_name: String, timeout_sec := 5.0) -> void:
	var path = ProjectSettings.globalize_path(voice_manager.get_voice_path(file_name))
	var elapsed := 0.0
	while not FileAccess.file_exists(path) and elapsed < timeout_sec:
		await Engine.get_main_loop().process_frame
		elapsed += 1.0 / ProjectSettings.get_setting("display/window/handheld/fps", 60.0)
	if not FileAccess.file_exists(path):
		push_warning("Voice file not found after wait: " + path)

func say(player, text: String, voice: String, speed: float) -> Signal:
	await _wait_for_voice(voice)
	
	tts.connect("completed", Callable(self, "_on_tts_completed"))
	
	var voice_res = voice_manager.get_voice_path(voice)
	var abs_path = ProjectSettings.globalize_path(voice_res)
	tts.set_voice_path(abs_path)

	var pcm: PackedByteArray = tts.speak_to_buffer(text)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.stereo = false
	wav.mix_rate = tts.get_sample_rate() * speed
	wav.data = pcm

	player.stream = wav
	player.play()
	
	var samples := pcm.size() / 2  # 16-bit samples → 2 bytes
	var duration := float(samples) / wav.mix_rate

	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	add_child(timer)
	timer.start()
	timer.timeout.connect(_on_tts_completed, CONNECT_ONE_SHOT)

	return completed

func _on_tts_completed() -> void:
	emit_signal("completed")
