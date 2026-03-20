extends Control

func _process(delta: float) -> void:
	$TextureRect.position = Vector2($NinePatchRect.position.x-16, convert_to_scroll(SharedVars.player_z/3))
	$TextureRect2.position = Vector2($NinePatchRect.position.x-48, convert_to_scroll(SharedVars.flag_z/3))

func convert_to_scroll(val: float):
	return remap(val, 0, 1, $NinePatchRect.position.y, $NinePatchRect.position.y+$NinePatchRect.size.y-32)
