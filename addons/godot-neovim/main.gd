@tool
extends EditorPlugin
const Plugin := preload("res://addons/godot-neovim/plugin.gd")
var _plugin = Plugin.new();
func _enable_plugin() -> void:
	pass
func _enter_tree() -> void:
	add_child(_plugin)

func _exit_tree() -> void:
	pass

func _disable_plugin() -> void:
	pass
