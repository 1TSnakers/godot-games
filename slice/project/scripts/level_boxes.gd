extends CSGCombiner3D

func _ready() -> void:
	for i in range(1, 7):
		get_node("Level " + str(i)).hide()
	
	print("Level " + str(SharedVars.level))
	get_node("Level " + str(SharedVars.level)).show()

func _process(delta: float) -> void:
	var flag_node = get_node_or_null("Level " + str(SharedVars.level) + "/flag")
	SharedVars.flag_z = flag_node.position.z if flag_node else 100
