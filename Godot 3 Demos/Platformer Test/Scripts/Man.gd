extends RigidBody2D

export var name = "Kyle"

func _ready():
	pass

func _process(delta):
	if Input.is_key_pressed(KEY_P):
		$Popup.popup(Rect2(0,10,20,0))
	elif Input.is_key_pressed(KEY_O):
		not $Popup.hide()
	pass
