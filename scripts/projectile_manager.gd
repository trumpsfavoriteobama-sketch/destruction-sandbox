extends Node3D

# Manages projectiles and explosions

var explosion_scene = preload("res://scripts/explosion.gd")

func _ready() -> void:
	name = "ProjectileManager"

func _physics_process(delta: float) -> void:
	check_projectile_collisions()

func check_projectile_collisions() -> void:
	for child in get_children():
		if child is RigidBody3D and child.has_meta("is_shell") or child.has_meta("is_bomb"):
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsShapeQueryParameters3D.new()
			var sphere_shape = SphereShape3D.new()
			sphere_shape.radius = 1.0
			query.shape = sphere_shape
			query.transform = child.global_transform
			query.exclude = [child]
			
			var results = space_state.intersect_shape(query)
			
			if results.size() > 0:
				var damage = child.get_meta("damage") if child.has_meta("damage") else 100
				var blast_radius = child.get_meta("blast_radius") if child.has_meta("blast_radius") else 20
				
				# Create explosion
				var explosion = Node3D.new()
				explosion.position = child.global_position
				var explosion_script = preload("res://scripts/explosion.gd")
				explosion.set_script(explosion_script)
				explosion.damage = damage
				explosion.blast_radius = blast_radius
				add_child(explosion)
				
				child.queue_free()