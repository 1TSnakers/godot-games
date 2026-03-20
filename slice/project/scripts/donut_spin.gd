extends CSGTorus3D

@export var spin_speed: float = 1.5
@export var wobble_speed: float = 0.8
@export var wobble_amount: float = 0.3

var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	rotation.y += spin_speed * delta
	rotation.x = sin(time * wobble_speed) * wobble_amount
