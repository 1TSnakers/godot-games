extends Node3D

func _on_flag_entered(body: Node3D) -> void:
	SharedVars.level = SharedVars.level + 1
	get_tree().reload_current_scene()
