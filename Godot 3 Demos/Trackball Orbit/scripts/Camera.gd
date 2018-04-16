extends Camera

export var mouseInvert					= false
export var mouseStrength				= 1.111
export var inertiaStrength				= 1.0
export(float, 0, 1, 0.005) var friction = 0.07

var _cameraUp							= Vector3(0, 1, 0)
var _cameraRight						= Vector3(1, 0, 0)
var _epsilon							= 0.0001
var _dragInertia						= Vector2(0, 0)

var _mouseRotDragStart
var _mouseRotDragPosition

export (int) var max_zoom_length				= 100
export (int) var min_zoom_length				= 5
export (float, 0.1, 1, 0.1) var zoomSteps		= 0.2
export (float) var rotationSteps				= 1.5

func getNormalizedMousePosition():
	return get_viewport().get_mouse_position() / get_viewport().get_visible_rect().size

func applyRotationFromTangent(tangent):
	var tr = get_transform()
	var up = tr.basis.xform(_cameraUp)
	var rg = tr.basis.xform(_cameraRight)
	var upQuat = Quat(up, -1 * tangent.x * TAU)
	var rgQuat = Quat(rg, -1 * tangent.y * TAU)
	set_transform(Transform(upQuat * rgQuat) * tr)

func _ready():
	self.transform.origin = Vector3(0, 15, 15)
	self.look_at(get_parent().transform.origin, _cameraUp)

func _input(event):
	
	## Top/Down View at keystroke
	if Input.is_action_just_pressed("camTopDownView"):
		self.transform.origin = Vector3(0, 15, 0)
		self.look_at(self.get_parent().transform.origin, _cameraRight)
	
	## Roll the camera left/right
	elif Input.is_action_pressed("camRollRight"):
		var prevRot = self.get_rotation_degrees()
		if prevRot[2] < -360:
			prevRot[2] += 360
		self.set_rotation_degrees(prevRot + Vector3(0, 0, -rotationSteps))
	
	elif Input.is_action_pressed("camRollLeft"):
		var prevRot = self.get_rotation_degrees()
		if prevRot[2] > 360:
			prevRot[2] -= 360
		self.set_rotation_degrees(prevRot + Vector3(0, 0, rotationSteps))
	
	## middle mouse first click
	if Input.is_action_just_pressed("midMouseButton"):
		## filter button event
		if event is InputEventMouseButton:
			if event.pressed:
				_mouseRotDragStart = getNormalizedMousePosition()
			else:
				_mouseRotDragStart = null
			_mouseRotDragPosition = _mouseRotDragStart
	
	## zoom in
	elif Input.is_action_just_pressed("mouseWheelUp"):
		if self.transform.origin.distance_to(Vector3(0, 0, 0)) >= min_zoom_length:
			self.transform.origin *= (1 - zoomSteps)

	## zoom out
	elif Input.is_action_just_pressed("mouseWheelDown"):
		if self.transform.origin.distance_to(Vector3(0, 0, 0)) <= max_zoom_length:
			self.transform.origin *= (1 + zoomSteps)

func _process(delta):
	
	if Input.is_action_pressed("midMouseButton") and _mouseRotDragPosition != null:
		var _currentDragPosition = getNormalizedMousePosition()
		_dragInertia += (_currentDragPosition - _mouseRotDragPosition) * mouseStrength * (-0.1 if mouseInvert else 0.1)
		_mouseRotDragPosition = _currentDragPosition
		var inertia = _dragInertia.length()
		if inertia > _epsilon:
			applyRotationFromTangent(_dragInertia * inertiaStrength)
			_dragInertia = _dragInertia * (1 - friction)
		elif inertia > 0:
			_dragInertia.x = 0
			_dragInertia.y = 0