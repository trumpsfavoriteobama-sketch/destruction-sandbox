extends Node3D

# City generator - creates destructible buildings

var buildings = []
var grid_size = 50
var building_density = 0.7

func generate_city() -> void:
	print("Generating city...")
	
	# Create ground
	create_ground()
	
	# Create buildings grid
	for x in range(-5, 5):
		for z in range(-5, 5):
			if randf() < building_density:
				create_building(x * grid_size, z * grid_size)
	
	print("City generated with ", buildings.size(), " buildings")

func create_ground() -> void:
	var ground = Node3D.new()
	ground.name = "Ground"
	add_child(ground)
	
	# Create mesh
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(1000, 1000)
	mesh_instance.mesh = plane_mesh
	mesh_instance.position.y = -1
	ground.add_child(mesh_instance)
	
	# Create collision
	var collision = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1000, 2, 1000)
	collision_shape.shape = box_shape
	collision_shape.position.y = -1
	collision.add_child(collision_shape)
	ground.add_child(collision)
	
	# Add material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.4, 0.3)
	mesh_instance.set_surface_override_material(0, material)

func create_building(x: float, z: float) -> void:
	var building = Node3D.new()
	building.name = "Building_" + str(buildings.size())
	building.position = Vector3(x, 0, z)
	add_child(building)
	
	# Random building properties
	var width = randf_range(15, 30)
	var depth = randf_range(15, 30)
	var height = randf_range(20, 50)
	
	# Create mesh
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(width, height, depth)
	mesh_instance.mesh = box_mesh
	mesh_instance.position.y = height / 2
	building.add_child(mesh_instance)
	
	# Create RigidBody for destruction
	var rigid_body = RigidBody3D.new()
	rigid_body.mass = 1.0
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(width, height, depth)
	collision_shape.shape = box_shape
	collision_shape.position.y = height / 2
	rigid_body.add_child(collision_shape)
	building.add_child(rigid_body)
	
	# Add destruction script
	var destruction_script = preload("res://scripts/destructible.gd")
	rigid_body.set_script(destruction_script)
	rigid_body.add_meta("max_health", 100)
	rigid_body.add_meta("current_health", 100)
	
	# Add material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(randf_range(0.5, 0.9), randf_range(0.4, 0.8), randf_range(0.3, 0.7))
	material.roughness = 0.8
	mesh_instance.set_surface_override_material(0, material)
	
	buildings.append(rigid_body)