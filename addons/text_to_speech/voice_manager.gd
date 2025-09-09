extends Node
class_name VoiceManager

const VOICE_DIR_RES := "res://addons/text_to_speech/voices"
const VOICE_DIR_USER := "user://voices"

func ensure_voices_installed() -> void:
	var voices_dir := "res://addons/text_to_speech/voices"
	var user_dir := "user://voices"

	DirAccess.make_dir_recursive_absolute(user_dir)

	var d = DirAccess.open(voices_dir)
	if not d:
		return

	d.list_dir_begin()
	var fname = d.get_next()
	while fname != "":
		if not d.current_is_dir() and fname.ends_with(".flitevox.res"):
			var src : String = voices_dir + "/" + fname
			var dst : String = user_dir + "/" + fname
			if not FileAccess.file_exists(dst):
				var bytes = FileAccess.get_file_as_bytes(src)
				var f = FileAccess.open(dst, FileAccess.WRITE)
				if f:
					f.store_buffer(bytes)
					f.close()
		fname = d.get_next()
	d.list_dir_end()

## Get absolute path to a given voice
func get_voice_path(voice_file: String) -> String:
	var abs_path = ProjectSettings.globalize_path(VOICE_DIR_USER + "/" + voice_file)
	return abs_path
