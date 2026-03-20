extends Node3D

# Assign these in the Inspector.
@export var csg_root: CSGShape3D
@export var max_boxes: int = 64

func _ready() -> void:
	await get_tree().process_frame
	var mat = csg_root.material_override as ShaderMaterial
	if mat == null:
		push_error("csg_root has no ShaderMaterial assigned to material_override.")
		return
	mat.set_shader_parameter("color_seed", randi())
	update_csg_colors(csg_root, mat)

func collect_csg_leaves(node: Node, leaves: Array) -> void:
	for child in node.get_children():
		if child.get_child_count() > 0:
			collect_csg_leaves(child, leaves)
		if child is CSGShape3D and not child is CSGCombiner3D:
			leaves.append(child)

func update_csg_colors(csg_root_node: CSGShape3D, mat: ShaderMaterial) -> void:
	var leaves: Array = []
	collect_csg_leaves(csg_root_node, leaves)

	if leaves.size() > max_boxes:
		push_warning("CSG leaf count (%d) exceeds max_boxes (%d). Some boxes will be ignored." \
			% [leaves.size(), max_boxes])

	var mins := PackedVector3Array()
	var maxs := PackedVector3Array()

	for i in range(min(leaves.size(), max_boxes)):
		var leaf = leaves[i]
		# get_aabb() returns local-space bounds; transform to world space manually.
		var local_aabb: AABB = leaf.get_aabb()
		var world_aabb: AABB = leaf.global_transform * local_aabb
		mins.append(world_aabb.position)
		maxs.append(world_aabb.position + world_aabb.size)

	var count := mins.size()

	# Pad to max_boxes so uniform array size stays constant.
	while mins.size() < max_boxes:
		mins.append(Vector3.ZERO)
		maxs.append(Vector3.ZERO)

	mat.set_shader_parameter("box_mins",  mins)
	mat.set_shader_parameter("box_maxs",  maxs)
	mat.set_shader_parameter("box_count", count)

	print("CSG color shader: assigned %d leaf boxes." % count)

func _process(delta) -> void:
	$CSGCombiner3D/CSGBox3D.position.z = $player.position.z
	if SharedVars.is_3d:
		$"level boxes".show()
		$CSGCombiner3D.hide()
	else:
		$"level boxes".hide()
		$CSGCombiner3D.show()
