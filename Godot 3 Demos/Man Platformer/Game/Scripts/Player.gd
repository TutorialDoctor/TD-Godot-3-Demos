extends RigidBody2D

var player
var feet
var sprite
var snd_jump
var bounds

var speed = 600
var height = 400

func _ready():
	player = self
	player.mode =RigidBody2D.MODE_CHARACTER
	#player.set_contact_monitor(true)
	# Also you have to make sure all collisions are reported
	#player.set_max_contacts_reported(true)
	player.set_contact_monitor(true)
	player.set_max_contacts_reported(1)

	sprite = $Sprite
	feet = $Feet
	feet.enabled = true
	feet.add_exception(player)
	snd_jump = $jump
	bounds = get_parent().get_node("bounds")

func _input(event):
	if event is InputEventKey:
		if event.as_text() == "Q":
			get_tree().quit()
		if event.as_text() =="R":
			get_tree().reload_current_scene()

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		sprite.flip_h = false
		if feet.is_colliding():
			sprite.animation = "run"
		player.set_axis_velocity(Vector2(speed,0))
	elif Input.is_action_pressed("ui_left"):
		sprite.flip_h = true
		if feet.is_colliding():
			sprite.animation = "run"
		player.set_axis_velocity(Vector2(-speed,0))
	elif not feet.is_colliding():
		sprite.animation = "air"
	elif feet.is_colliding():
		sprite.animation = "idle"
	if Input.is_action_pressed("ui_up"):
		if feet.is_colliding():
			sprite.animation = "jump"
			player.apply_impulse(Vector2(0,0),Vector2(0,-height))
			if Input.is_action_just_pressed("ui_up"):
				snd_jump.playing= true

	if bounds in player.get_colliding_bodies():
		get_tree().reload_current_scene()
