extends Node3D

# Player controller and camera

const SPEED = 5.0
const MOUSE_SENSITIVITY = 0.003
const JUMP_VELOCITY = 4.5

var velocity = Vector3.ZERO
var camera: Camera3D
var body: CharacterBody3D
var weapon_manager: Node
var current_vehicle: Node3D = null
var is_aiming: bool = false

func _ready() -> void:
	# Create character body
	body = CharacterBody3D.new()
	body.name = "PlayerBody"
	add_child(body)
	
	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	var capsule_shape = CapsuleShape3D.new()
	capsule_shape.radius = 0.4
	capsule_shape.height = 1.8
	collision_shape.shape = capsule_shape
	body.add_child(collision_shape)
	
	# Create camera
	camera = Camera3D.new()
	camera.name = "Camera"
	camera.position.y = 1.6
	body.add_child(camera)
	
	# Set as current camera
	camera.current = true
	
	# Setup weapon manager
	weapon_manager = preload("res://scripts/weapon_manager.gd").new()
	add_child(weapon_manager)
	
	# Input capture
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	# Toggle mouse capture
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	# Handle aiming
	is_aiming = Input.is_action_pressed("aim")
	
	# Handle firing
	if Input.is_action_just_pressed("fire"):
		weapon_manager.fire(camera.global_position, camera.global_transform.basis.z)

func _physics_process(delta: float) -> void:
	# Only move if not in vehicle
	if current_vehicle == null:
		handle_movement(delta)

func handle_movement(delta: float) -> void:
	# Get input direction
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Apply gravity
	if not body.is_on_floor():
		velocity.y -= 9.8 * delta
	
	# Jump
	if Input.is_action_just_pressed("ui_accept") and body.is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	body.velocity = velocity
	body.move_and_slide()