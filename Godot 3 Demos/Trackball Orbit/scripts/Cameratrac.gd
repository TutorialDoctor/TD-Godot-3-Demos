extends Camera

# Makes this Camera respond to input from mouse, keyboard, joystick and touch,
# in order to rotate around its parent node while facing it.
# We're using quaternions, so no infamous gimbal lock.
# The camera has inertia for a smoother experience.

# todo: test if touch works on android and html5, try SCREEN_DRAG otherwise

# Requirements
# ------------
# Godot 3.x

# Usage
# -----
# Attach as script to a Camera, and make the camera a child of the node to trackball around.
# Make sure your camera initially faces said node, and is at a proper distance from it.
# The initial position of your camera matters. The node does not need to be in the center.

# You can also use this camera to look around you if you place it atop its parent node, spatially.
# It's going to rotate around itself, and that amounts to looking around.
# You'll probably want to set mouseInvert and keyboardInvert to true in that case.

# License
# -------
# Same as Godot, ie. permissive MIT. (https://godotengine.org/license)

# If you feel generous and want to feed me so I can math more of those,
# I enjoy the taste of ETH Ξ 0xB48C3B718a1FF3a280f574Ad36F04068d7EAf498
# You can blame antoine@goutenoir.com for the bugs, crashes and burns.
# Seriously, useful feedback is always appreciated – we can't test everything.



export var mouseEnabled			= true
export var mouseInvert			= false
export var mouseStrength		= 1.111
export var keyboardEnabled		= true
export var keyboardInvert		= false
export var keyboardStrength		= 1.111
export var joystickEnabled		= true
export var joystickInvert		= false
export var joystickStrength		= 1.111
export var joystickThreshold	= 0.09	# the resting state of my joystick's x-axis is -0.05 T.T
export var joystickDevice		= 0
export var inertiaStrength		= 1.0	# multiplier applied to all strengths
export(float, 0, 1, 0.005) var friction	= 0.07



var _iKnowWhatIAmDoing = false	# should we skip assertions?
var _cameraUp = Vector3(0, 1, 0)
var _cameraRight = Vector3(1, 0, 0)
var _epsilon = 0.0001
var _mouseDragStart
var _mouseDragPosition
var _dragInertia = Vector2(0, 0)


func _ready():
	set_process_input(true)
	set_process(true)

	# It's best to catch future divisions by 0 before they happen.
	# Note that we don't need this check if the mouse support is disabled.
	# In case you know what you're doing, there's a property you can change.
	assert _iKnowWhatIAmDoing or get_viewport().get_visible_rect().get_area()
	#print("Trackball Camera around %s is ready. ♥" % get_parent().get_name())


func _input(ev):
	if mouseEnabled and ev is InputEventMouseButton:
		if ev.pressed:
			_mouseDragStart = getNormalizedMousePosition()
		else:
			_mouseDragStart = null
		_mouseDragPosition = _mouseDragStart


func _process(delta):
	if mouseEnabled and _mouseDragPosition != null:
		var _currentDragPosition = getNormalizedMousePosition()
		_dragInertia += (_currentDragPosition - _mouseDragPosition) \
						* mouseStrength * (-0.1 if mouseInvert else 0.1)
		_mouseDragPosition = _currentDragPosition

	if keyboardEnabled:
		var key_i = -1 if keyboardInvert else 1
		var key_s = keyboardStrength / 1000.0	# exported floats get truncated
		if Input.is_key_pressed(KEY_LEFT):
			_dragInertia += Vector2(key_i * key_s, 0)
		if Input.is_key_pressed(KEY_RIGHT):
			_dragInertia += Vector2(-1 * key_i * key_s, 0)
		if Input.is_key_pressed(KEY_UP):
			_dragInertia += Vector2(0, key_i * key_s)
		if Input.is_key_pressed(KEY_DOWN):
			_dragInertia += Vector2(0, -1 * key_i * key_s)

	if joystickEnabled:
		var joy_h = Input.get_joy_axis(joystickDevice, 0)	# left stick horizontal
		var joy_v = Input.get_joy_axis(joystickDevice, 1)	# left stick vertical
		var joy_i = -1 if joystickInvert else 1
		var joy_s = joystickStrength / 1000.0	# exported floats get truncated

		if abs(joy_h) > joystickThreshold:
			_dragInertia += Vector2(joy_i * joy_h * joy_h * sign(joy_h) * joy_s, 0)
		if abs(joy_v) > joystickThreshold:
			_dragInertia += Vector2(0, joy_i * joy_v * joy_v * sign(joy_v) * joy_s)

	var inertia = _dragInertia.length()
	if inertia > _epsilon:
		applyRotationFromTangent(_dragInertia * inertiaStrength)
		_dragInertia = _dragInertia * (1 - friction)
	elif inertia > 0:
		_dragInertia.x = 0
		_dragInertia.y = 0


# Convenience method for you to move the camera around.
# inertia is a Vector2 in the normalized right-handed x/y of the screen.
func addInertia(inertia):
	_dragInertia += inertia


func getNormalizedMousePosition():
	return get_viewport().get_mouse_position() / get_viewport().get_visible_rect().size


func applyRotationFromTangent(tangent):
	var tr = get_transform()  # not get_camera_transform, unsure why
	var up = tr.basis.xform(_cameraUp)
	var rg = tr.basis.xform(_cameraRight)
	var upQuat = Quat(up, -1 * tangent.x * TAU)
	var rgQuat = Quat(rg, -1 * tangent.y * TAU)
	set_transform(Transform(upQuat * rgQuat) * tr)	# money shot!