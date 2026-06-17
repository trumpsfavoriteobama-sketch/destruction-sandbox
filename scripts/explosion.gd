extends Node3D

# Explosion effect and damage

var blast_radius = 30.0
var damage = 150.0
var explosion_force = 100.0

func _ready() -> void:
	# Create visual effect
	var sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 2.0
	sphere.mesh = sphere_mesh
	add_child(sphere)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.8, 0.0, 0.8)
	sphere.set_surface_override_material(0, material)
	
	# Apply damage to nearby objects
	apply_damage()
	
	# Fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sphere, "scale", Vector3(4, 4, 4), 0.3)
	tween.tween_property(material, "albedo_color", Color(1.0, 0.8, 0.0, 0.0), 0.3)
	
	await tween.finished
	queue_free()

func apply_damage() -> void:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = blast_radius
	query.shape = sphere_shape
	query.transform = global_transform
	
	var results = space_state.intersect_shape(query)
	
	for collision in results:
		var collider = collision.collider
		if collider.has_method("take_damage"):
			collider.take_damage(damage)
		
		if collider is RigidBody3D:
			var direction = (collider.global_position - global_position).normalized()
			collider.apply_central_impulse(direction * explosion_force)