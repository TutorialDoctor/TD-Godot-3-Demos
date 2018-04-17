extends Spatial

var base_picker
var base_mat
var picker_color
var hair_mat
var hair_picker

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	base_picker = $GUI/ColorPickerButton
	hair_picker = $GUI/ColorPickerButton2
	base_mat= $head.get('material/7')
	hair_mat = $head.get('material/8')

func _process(delta):
	recolor(base_mat,base_picker)
	recolor(hair_mat,hair_picker)

# Recolor material "x" with color picker "y"
func recolor(mat,col):
	picker_color = col.get_pick_color()
	mat.albedo_color = picker_color
	"""
	if picker_color.r <= 1:
		print('red'+str(picker_color.r))
	if picker_color.g <=1:
		print('green'+str(picker_color.g))
	if picker_color.b <= 1:
		print('blue'+str(picker_color.b))"""

	