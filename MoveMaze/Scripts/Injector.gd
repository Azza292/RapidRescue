# Path_Injector - Store information regarding injection location and direction and handle input.

extends Spatial

var disabled setget set_disabled, get_disabled
var hovered setget set_hovered, get_hovered

signal pressed

# What direction the path is injected towards.
var inj_direction
# Where the path get injected.
var inj_board_index

func get_hovered():
	return hovered

func get_disabled():
	return disabled

func set_hovered(value):
	if value:
		var tmp = $Mesh.get_surface_material(0).duplicate()
		tmp.albedo_color = Color('f58765')
		$Mesh.set_surface_material(0, tmp)
	else:
		$Mesh.get_surface_material(0).albedo_color = Color(1, 1, 1)

func set_disabled(value):
	visible = !value
	disabled = value

func setup(inj_board_index, inj_direction):
	self.inj_board_index = inj_board_index
	self.inj_direction = inj_direction
	# Look toward Injection Direction
	rotation.y = atan2(inj_direction.x, inj_direction.y) - PI

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_pressed() and !disabled:
		press_injector()

func press_injector():
	emit_signal("pressed", self)