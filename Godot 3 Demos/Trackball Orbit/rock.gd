extends MeshInstance



func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	self.rotate_y(.1)
	self.rotate_z(.05)
	self.rotate_x(.05)

