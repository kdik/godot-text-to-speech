@tool
extends EditorPlugin

func _enter_tree():
	# Path to your singleton script
	var singleton_path = "res://addons/text_to_speech/my_singleton.gd"
	var singleton_name = "MySingleton"
#
	#if not Engine.has_singleton(singleton_name):
		#ProjectSettings.add_singleton({
			#"name": singleton_name,
			#"path": singleton_path,
			#"autoload": true
		#})
		#print("Singleton added:", singleton_name)
