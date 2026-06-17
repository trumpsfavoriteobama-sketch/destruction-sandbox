extends Node3D

# Tank vehicle script

var body: RigidBody3D
var turret: Node3D
var barrel: Node3D
var speed = 15.0
var rotation_speed = 2.0
var turret_rotation_speed = 3.0
var camera: Camera3D
var player: Node3D
var current_ammo = 50
var fire_cooldown = 0.0

func _ready() -> void:
	# Create tank body
	body = RigidBody3D.new()
	body.name = "TankBody"
	add_child(body)
	
	# Tank chassis mesh
	var chassis = MeshInstance3D.new()
	var chassis_mesh = BoxMesh.new()
	chassis_mesh.size = Vector3(4, 2, 8)
	chassis.mesh = chassis_mesh
	chassis.position.y = 1.5
	body.add_child(chassis)
	
	var chassis_material = StandardMaterial3D.new()
	chassis_material.albedo_color = Color(0.3, 0.5, 0.3)
	chassis.set_surface_override_material(0, chassis_material)
	
	# Collision
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(4, 2, 8)
	collision.shape = box_shape
	collision.position.y = 1.5
	body.add_child(collision)
	
	# Create turret
	turret = Node3D.new()
	turret.name = "Turret"
	turret.position.y = 3.0
	body.add_child(turret)
	
	var turret_mesh = MeshInstance3D.new()
	var turret_shape = CylinderMesh.new()
	turret_shape.radius = 1.0
	turret_shape.height = 1.5
	turret_mesh.mesh = turret_shape
	turret.add_child(turret_mesh)
	
	var turret_material = StandardMaterial3D.new()
	turret_material.albedo_color = Color(0.4, 0.6, 0.4)
	turret_mesh.set_surface_override_material(0, turret_material)
	
	# Create barrel
	barrel = Node3D.new()
	barrel.name = "Barrel"
	barrel.position.z = 2.0
	turret.add_child(barrel)
	
	var barrel_mesh = MeshInstance3D.new()
	var barrel_shape = CylinderMesh.new()
	barrel_shape.radius = 0.3
	barrel_shape.height = 3.0
	barrel_mesh.mesh = barrel_shape
	barrel_mesh.rotation.x = PI / 2
	barrel_mesh.position.z = 1.5
	barrel.add_child(barrel_mesh)
	
	var barrel_material = StandardMaterial3D.new()
	barrel_material.albedo_color = Color(0.2, 0.2, 0.2)
	barrel_mesh.set_surface_override_material(0, barrel_material)
	
	# Create camera
	camera = Camera3D.new()
	camera.position = Vector3(0, 3, -6)
	add_child(camera)

func _process(delta: float) -> void:
	if fire_cooldown > 0:
		fire_cooldown -= delta

func _physics_process(delta: float) -> void:
	if not camera.current:
		return
	
	# Tank movement
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_dir.y != 0:
		body.linear_velocity = -global_transform.basis.z * input_dir.y * speed
	else:
		body.linear_velocity.z = move_toward(body.linear_velocity.z, 0, speed * delta)
	
	# Tank rotation
	if input_dir.x != 0:
		body.angular_velocity.y = input_dir.x * rotation_speed
	else:
		body.angular_velocity.y = move_toward(body.angular_velocity.y, 0, rotation_speed * delta)
	
	# Turret aiming with mouse
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mouse_pos = get_viewport().get_mouse_position()
		var viewport_size = get_viewport().get_visible_rect().size
		var center = viewport_size / 2
		var mouse_offset = mouse_pos - center
		
		turret.rotation.y += mouse_offset.x * 0.01
		barrel.rotation.x -= mouse_offset.y * 0.01
		barrel.rotation.x = clamp(barrel.rotation.x, -PI/3, PI/6)
	
	# Fire
	if Input.is_action_just_pressed("fire") and fire_cooldown <= 0 and current_ammo > 0:
		fire_shell()

func fire_shell() -> void:
	current_ammo -= 1
	fire_cooldown = 1.5
	
	var shell = Node3D.new()
	shell.position = barrel.global_position + barrel.global_transform.basis.z * 2
	
	var shell_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.3
	shell_mesh.mesh = sphere
	shell.add_child(shell_mesh)
	
	var shell_material = StandardMaterial3D.new()
	shell_material.albedo_color = Color(0.1, 0.1, 0.1)
	shell_mesh.set_surface_override_material(0, shell_material)
	
	var rigid = RigidBody3D.new()
	var collision = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.3
	collision.shape = sphere_shape
	rigid.add_child(collision)
	
	rigid.linear_velocity = barrel.global_transform.basis.z * 100
	rigid.add_meta("damage", 150)
	rigid.add_meta("blast_radius", 25)
	rigid.add_meta("is_shell", true)
	
	get_parent().add_child(rigid)
	shell.add_child(rigid)

func exit_tank() -> void:
	camera.current = false