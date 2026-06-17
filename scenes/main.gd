extends Node3D

# Game manager script

var player: Node3D
var city_map: Node3D
var current_weapon: String = "revolver"
var current_vehicle: String = "none"

func _ready() -> void:
	print("Destruction Sandbox - Initializing...")
	setup_scene()
	setup_player()
	setup_city()

func setup_scene() -> void:
	# Setup world
	var world_env = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.2, 0.3, 0.4)
	env.ambient_light_source = Environment.AMBIENT_LIGHT_DISABLED
	world_env.environment = env
	add_child(world_env)
	
	# Add sun light
	var sun = DirectionalLight3D.new()
	sun.rotation.x = -PI / 4
	sun.rotation.y = PI / 6
	sun.energy_multiplier = 1.5
	add_child(sun)

func setup_player() -> void:
	player = Node3D.new()
	player.name = "Player"
	add_child(player)
	
	# Player controller
	var player_script = preload("res://scripts/player_controller.gd")
	player.set_script(player_script)

func setup_city() -> void:
	city_map = Node3D.new()
	city_map.name = "CityMap"
	add_child(city_map)
	
	# Generate city
	var city_script = preload("res://scripts/city_generator.gd")
	city_map.set_script(city_script)
	city_map.generate_city()

func _process(delta: float) -> void:
	pass