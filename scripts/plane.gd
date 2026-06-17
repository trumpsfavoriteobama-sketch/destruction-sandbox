extends Node3D

# Plane vehicle script

var body: RigidBody3D
var camera: Camera3D
var speed = 30.0
var lift = 5.0
var current_bombs = 20
var fire_cooldown = 0.0
var velocity = Vector3.ZERO

func _ready() -> void:
	# Create plane body
	body = RigidBody3D.new()
	body.name = "PlaneBody"
	add_child(body)
	
	# Fuselage
	var fuselage = MeshInstance3D.new()
	var fuselage_mesh = BoxMesh.new()
	fuselage_mesh.size = Vector3(2, 1.5, 6)
	fuselage.mesh = fuselage_mesh
	body.add_child(fuselage)
	
	var fuselage_material = StandardMaterial3D.new()
	fuselage_material.albedo_color = Color(0.8, 0.7, 0.2)
	fuselage.set_surface_override_material(0, fuselage_material)
	
	# Wings
	var wings = MeshInstance3D.new()
	var wing_mesh = BoxMesh.new()
	wing_mesh.size = Vector3(12, 0.3, 3)
	wings.mesh = wing_mesh
	body.add_child(wings)
	
	var wing_material = StandardMaterial3D.new()
	wing_material.albedo_color = Color(0.7, 0.6, 0.1)
	wings.set_surface_override_material(0, wing_material)
	
	# Collision
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(2, 1.5, 6)
	collision.shape = box_shape
	body.add_child(collision)
	
	# Camera
	camera = Camera3D.new()
	camera.position = Vector3(0, 2, -8)
	add_child(camera)

func _process(delta: float) -> void:
	if fire_cooldown > 0:
		fire_cooldown -= delta

func _physics_process(delta: float) -> void:
	if not camera.current:
		return
	
	# Get input
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var vertical = Input.get_axis("ui_select", "ui_cancel")
	
	# Forward movement
	velocity = -global_transform.basis.z * speed
	
	# Pitch
	if input_dir.y != 0:
		rotate_object_local(Vector3.x, input_dir.y * 0.03)
	
	# Roll
	if input_dir.x != 0:
		rotate_object_local(Vector3.z, -input_dir.x * 0.02)
	
	# Yaw
	rotate_object_local(Vector3.y, input_dir.x * 0.02)
	
	# Vertical movement
	if vertical != 0:
		velocity.y = vertical * lift
	
	body.linear_velocity = velocity
	
	# Fire bombs
	if Input.is_action_just_pressed("fire") and fire_cooldown <= 0 and current_bombs > 0:
		drop_bomb()

func drop_bomb() -> void:
	current_bombs -= 1
	fire_cooldown = 0.3
	
	var bomb = Node3D.new()
	bomb.position = global_position + Vector3.DOWN * 3
	
	var bomb_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.4
	bomb_mesh.mesh = sphere
	bomb.add_child(bomb_mesh)
	
	var bomb_material = StandardMaterial3D.new()
	bomb_material.albedo_color = Color(0.2, 0.2, 0.2)
	bomb_mesh.set_surface_override_material(0, bomb_material)
	
	var rigid = RigidBody3D.new()
	var collision = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.4
	collision.shape = sphere_shape
	rigid.add_child(collision)
	
	rigid.linear_velocity = Vector3.DOWN * 15
	rigid.add_meta("damage", 300)
	rigid.add_meta("blast_radius", 40)
	rigid.add_meta("is_bomb", true)
	
	get_parent().add_child(rigid)
	bomb.add_child(rigid)

func exit_plane() -> void:
	camera.current = false