extends Node

# Weapon system manager

var current_weapon: String = "revolver"
var weapons = {}
var last_fire_time = {}

func _ready() -> void:
	setup_weapons()

func setup_weapons() -> void:
	weapons = {
		"revolver": {
			"damage": 25,
			"fire_rate": 0.2,
			"range": 100,
			"bullet_speed": 100
		},
		"rocket_launcher": {
			"damage": 200,
			"fire_rate": 1.0,
			"range": 200,
			"blast_radius": 20
		},
		"tank_shell": {
			"damage": 300,
			"fire_rate": 2.0,
			"range": 300,
			"blast_radius": 30
		},
		"plane_bomb": {
			"damage": 500,
			"fire_rate": 0.5,
			"range": 400,
			"blast_radius": 50
		}
	}
	
	for weapon_name in weapons.keys():
		last_fire_time[weapon_name] = 0.0

func fire(from_pos: Vector3, direction: Vector3) -> void:
	var weapon_data = weapons[current_weapon]
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if current_time - last_fire_time[current_weapon] < weapon_data["fire_rate"]:
		return
	
	last_fire_time[current_weapon] = current_time
	
	match current_weapon:
		"revolver":
			fire_hitscan(from_pos, direction, weapon_data)
		"rocket_launcher":
			fire_projectile(from_pos, direction, weapon_data, "rocket")
		"tank_shell":
			fire_projectile(from_pos, direction, weapon_data, "shell")
		"plane_bomb":
			fire_projectile(from_pos, direction, weapon_data, "bomb")

func fire_hitscan(from_pos: Vector3, direction: Vector3, weapon_data: Dictionary) -> void:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from_pos, from_pos + direction * weapon_data["range"])
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_object = result.collider
		if hit_object.has_method("take_damage"):
			hit_object.take_damage(weapon_data["damage"])

func fire_projectile(from_pos: Vector3, direction: Vector3, weapon_data: Dictionary, proj_type: String) -> void:
	var projectile = Node3D.new()
	projectile.position = from_pos
	
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.1 if proj_type == "rocket" else 0.2
	mesh_instance.mesh = sphere_mesh
	projectile.add_child(mesh_instance)
	
	var rigid_body = RigidBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.1 if proj_type == "rocket" else 0.2
	collision_shape.shape = sphere_shape
	rigid_body.add_child(collision_shape)
	
	rigid_body.linear_velocity = direction * weapon_data["bullet_speed"]
	rigid_body.add_meta("weapon_type", proj_type)
	rigid_body.add_meta("damage", weapon_data["damage"])
	rigid_body.add_meta("blast_radius", weapon_data.get("blast_radius", 0))
	
	get_parent().add_child(rigid_body)

func switch_weapon(weapon_name: String) -> void:
	if weapon_name in weapons:
		current_weapon = weapon_name
		print("Switched to: ", weapon_name)