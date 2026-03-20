extends CharacterBody3D
var speed = 1
var jump_speed = 4
const COYOTE_TIME = 0.2
var coyote_timer = 0.0
var was_on_floor = false
func _physics_process(delta):
	
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
	up_direction = Vector3.UP
	
	# Track coyote time
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		was_on_floor = true
	else:
		coyote_timer -= delta
	
	# Add the gravity.
	if is_on_floor():
		velocity.y = 0
	else:
		velocity.y += get_gravity().y * delta
	
	# dont work with input if in 3d
	if not SharedVars.is_3d or SharedVars.move_in_3d:
		# Handle Jump.
		# coyote_timer > 0 means either on floor OR just walked off an edge
		if Input.is_action_just_pressed("jump") and coyote_timer > 0:
			velocity.y = jump_speed
			coyote_timer = 0.0  # consume it so you can't double-jump
		# Get the input direction.
		var direction = Input.get_axis("left", "right")
		velocity.x = direction * speed
	
	if velocity.x > 0:
		$AnimatedSprite3D.flip_h = false
		$AnimatedSprite3D.position.x = abs($AnimatedSprite3D.position.x)
	elif velocity.x < 0:
		$AnimatedSprite3D.flip_h = true
		$AnimatedSprite3D.position.x = -abs($AnimatedSprite3D.position.x)
	
	# dont work with input if in 3d
	if not SharedVars.is_3d or SharedVars.move_in_3d:
		var slice_dir = Input.get_axis("forward", "back")
		velocity.z = slice_dir * speed
	
	# Animation logic
	var anim = $AnimatedSprite3D
	if velocity.y > 0.1:
		anim.play("jump")
	elif abs(velocity.x) > 0.01 or abs(velocity.z) > 0.01:
		anim.play("walk")
	else:
		anim.play("idle")
	
	SharedVars.player_z = position.z
	position.z = clamp(position.z, 0 , 3)
	position.x = clamp(position.x, 0 , 5)
	move_and_slide()
