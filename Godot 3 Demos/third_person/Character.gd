extends KinematicBody

var gravity = 9.8
var jump = 5
var captain = Vector3()
var speed = 10
var acceleration = 5

var mouse_sensitivity = 0.1

var direction = Vector3()
var velocity = Vector3()

onready var pivot = $Pivot
onready var gunpivot = $GunPivot
onready var feet = $Feet


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	feet.enabled = true
	feet.add_exception(self)

func _input(event):
	
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		pivot.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(-90), deg2rad(90))
		gunpivot.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		gunpivot.rotation.x =  clamp(pivot.rotation.x, deg2rad(-90), deg2rad(90))
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventKey:
		if event.as_text() == "Q":
			get_tree().quit()
		if event.as_text() =="R":
			get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	direction = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
		
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
		
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	if not feet.is_colliding():
		captain.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and feet.is_colliding():
		captain.y = jump
	
	move_and_slide(captain, Vector3.UP)
	
	direction = direction.normalized()
	velocity = direction * speed
	velocity.linear_interpolate(velocity, acceleration * delta)
	move_and_slide(velocity, Vector3.UP)
