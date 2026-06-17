extends RigidBody3D

# Destructible object script

var current_health: float
var max_health: float = 100

func _ready() -> void:
	if has_meta("max_health"):
		max_health = get_meta("max_health")
	if has_meta("current_health"):
		current_health = get_meta("current_health")
	else:
		current_health = max_health

func take_damage(amount: float) -> void:
	current_health -= amount
	
	if current_health <= 0:
		destroy()

func destroy() -> void:
	# Add destruction effect
	if get_node_or_null("MeshInstance3D"):
		var mesh_instance = get_node("MeshInstance3D")
		# Make it disappear
		mesh_instance.visible = false
	
	# Disable collision after brief delay
	await get_tree().create_timer(0.5).timeout
	queue_free()