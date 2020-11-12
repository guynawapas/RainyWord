extends KinematicBody2D
var speed = 200
var vel = Vector2()


func _ready():
	set_process(true)

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		var direction = get_global_mouse_position()-position-Vector2(600,100)
		move_and_slide(direction)


