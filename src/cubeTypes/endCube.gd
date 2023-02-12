extends Cube 
#@onready var winning_face_mesh_instance: MeshInstance3D = $ColorPlaque
#@onready var winning_face_mesh: Mesh = winning_face_mesh_instance.mesh
#var winning_face_initial_color: Color
#var winning_face_touched_color: Color

func _ready():
	super._ready()
	cube_type = END
	initial_color = Colors.end_cube_init_color
	touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color

func on_touch():
	super.on_touch()
	print("YOU WIN !!!")
	# TODO