extends Node
class_name VoiceManager

const VOICE_DIR_RES := "res://addons/text_to_speech/voices"
const VOICE_DIR_USER := "user://voices"

static var _voice_offloading_started := false

func ensure_voices_installed() -> void:
	if _voice_offloading_started:
		return
	_voice_offloading_started = true
	
	if OS.has_feature("editor"):
		return
	
	DirAccess.make_dir_recursive_absolute(VOICE_DIR_USER)

	var d = DirAccess.open(VOICE_DIR_RES)
	if not d:
		return

	d.list_dir_begin()
	var fname = d.get_next()
	while fname != "":
		if not d.current_is_dir() and fname.ends_with(".flitevox.res"):
			var src : String = VOICE_DIR_RES + "/" + fname
			var dst : String = VOICE_DIR_USER + "/" + fname
			if not FileAccess.file_exists(dst):
				var bytes = FileAccess.get_file_as_bytes(src)
				var f = FileAccess.open(dst, FileAccess.WRITE)
				if f:
					f.store_buffer(bytes)
					f.close()
		fname = d.get_next()
	d.list_dir_end()
	
func wait_for_voice(voice_path: String, timeout_sec := 5.0) -> void:
	var elapsed := 0.0
	await Engine.get_main_loop().process_frame
	while not FileAccess.file_exists(voice_path) and elapsed < timeout_sec:
		await Engine.get_main_loop().process_frame
		elapsed += 1.0 / ProjectSettings.get_setting("display/window/handheld/fps", 60.0)
	if not FileAccess.file_exists(voice_path):
		push_warning("Voice file not found after wait: " + voice_path)

# Flite cannot read voice files from .pck, so in an exported game the voices are extracted from the .pck to user://
func get_voice_path(voice_name: String) -> String:
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path(VOICE_DIR_RES + "/" + voice_name + ".flitevox.res")
	else:
		return ProjectSettings.globalize_path(VOICE_DIR_USER + "/" + voice_name + ".flitevox.res")
