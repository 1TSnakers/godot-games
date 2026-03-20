extends Camera3D

@onready var anim = $AnimationPlayer

var at_start = true  # tracks which pause point we're at

func _ready():
	anim.play("3d view")
	anim.seek(0.0, true)  # snap to 0s
	anim.pause()

func _on_button_pressed():
	if at_start:
		# play forward, pause at 2s
		anim.play("3d view")
		anim.speed_scale = 1.0
		at_start = false
		SharedVars.is_3d = true
	else:
		# play in reverse, pause at 0s
		anim.play_backwards("3d view")
		at_start = true

func _process(delta):
	if not anim.is_playing():
		return
	if not at_start and anim.current_animation_position >= 1.99:
		anim.seek(2.0, true)
		anim.pause()
	elif at_start and anim.current_animation_position <= 0.01:
		anim.seek(0.0, true)
		anim.pause()
		SharedVars.is_3d = false
		
func _unhandled_input(event):
	if event.is_action_pressed("cam_move"):  # replace with your action
		_on_button_pressed()
