extends MeshInstance

# class member variables go here, for example:
# var a = 2
export var rot_speed = -.05

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	self.rotate_y(rot_speed)
	
