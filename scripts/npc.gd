extends Node3D

# NPC character script

var body: CharacterBody3D
var mesh: MeshInstance3D
var speed = 5.0
var flee_distance = 30.0
var player: Node3D = null
var path_timer = 0.0
var current_target = Vector3.ZERO
var health = 50.0

func _ready() -> void:
	# Create character body
	body = CharacterBody3D.new()
	body.name = "NPCBody"
	add_child(body)
	
	# Create mesh
	mesh = MeshInstance3D.new()
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.3
	capsule_mesh.height = 1.8
	mesh.mesh = capsule_mesh
	body.add_child(mesh)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(randf_range(0.5, 1.0), randf_range(0.3, 0.8), randf_range(0.2, 0.6))
	mesh.set_surface_override_material(0, material)
	
	# Collision
	var collision = CollisionShape3D.new()
	var capsule_shape = CapsuleShape3D.new()
	capsule_shape.radius = 0.3
	capsule_shape.height = 1.8
	collision.shape = capsule_shape
	body.add_child(collision)
	
	# Pickup player reference
	if get_parent().get_parent().has_node("Player"):
		player = get_parent().get_parent().get_node("Player")

func _physics_process(delta: float) -> void:
	path_timer -= delta
	
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Flee if too close
		if distance_to_player < flee_distance:
			var flee_direction = (global_position - player.global_position).normalized()
			current_target = global_position + flee_direction * 50
			path_timer = 5.0
		
		# Random wandering
		elif path_timer <= 0:
			current_target = global_position + Vector3(randf_range(-30, 30), 0, randf_range(-30, 30))
			path_timer = randf_range(3, 8)
	
	# Move towards target
	var direction = (current_target - global_position).normalized()
	body.velocity = direction * speed
	body.velocity.y -= 9.8 * delta
	body.move_and_slide()

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		queue_free()