extends Node3D

# Enhanced main scene with all systems integrated

var player: Node3D
var city_map: Node3D
var npc_manager: Node3D
var projectile_manager: Node3D
var ui_menu: CanvasLayer
var current_weapon = "revolver"
var current_vehicle = "none"

func _ready() -> void:
	print("=== DESTRUCTION SANDBOX INITIALIZING ===")
	setup_world()
	setup_player()
	setup_city()
	setup_npcs()
	setup_ui()
	print("=== GAME READY ===")

func setup_world() -> void:
	# World environment
	var world_env = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.5, 0.7, 0.9)
	env.ambient_light_source = Environment.AMBIENT_LIGHT_DISABLED
	world_env.environment = env
	add_child(world_env)
	
	# Sun light
	var sun = DirectionalLight3D.new()
	sun.rotation.x = -PI / 4
	sun.rotation.y = PI / 6
	sun.energy_multiplier = 2.0
	add_child(sun)

func setup_player() -> void:
	player = Node3D.new()
	player.name = "Player"
	add_child(player)
	
	var player_script = preload("res://scripts/player_controller.gd")
	player.set_script(player_script)

func setup_city() -> void:
	city_map = Node3D.new()
	city_map.name = "CityMap"
	add_child(city_map)
	
	var city_script = preload("res://scripts/city_generator.gd")
	city_map.set_script(city_script)
	city_map.call_deferred("generate_city")

func setup_npcs() -> void:
	npc_manager = Node3D.new()
	npc_manager.name = "NPCManager"
	add_child(npc_manager)
	
	# Spawn NPCs
	for i in range(15):
		var npc = Node3D.new()
		npc.name = "NPC_" + str(i)
		npc.position = Vector3(randf_range(-200, 200), 2, randf_range(-200, 200))
		npc_manager.add_child(npc)
		
		var npc_script = preload("res://scripts/npc.gd")
		npc.set_script(npc_script)

func setup_ui() -> void:
	ui_menu = CanvasLayer.new()
	ui_menu.name = "UILayer"
	add_child(ui_menu)
	
	var menu_script = preload("res://scripts/ui_menu.gd")
	ui_menu.set_script(menu_script)

func _process(delta: float) -> void:
	# Vehicle switching
	if Input.is_action_just_pressed("interact"):
		handle_vehicle_switch()

func handle_vehicle_switch() -> void:
	match current_vehicle:
		"none":
			spawn_tank()
		"tank":
			spawn_plane()
		"plane":
			current_vehicle = "none"

func spawn_tank() -> void:
	var tank = Node3D.new()
	tank.name = "Tank"
	tank.position = player.position + Vector3(5, 0, 5)
	add_child(tank)
	
	var tank_script = preload("res://scripts/tank.gd")
	tank.set_script(tank_script)
	current_vehicle = "tank"

func spawn_plane() -> void:
	var plane = Node3D.new()
	plane.name = "Plane"
	plane.position = player.position + Vector3(0, 50, 0)
	add_child(plane)
	
	var plane_script = preload("res://scripts/plane.gd")
	plane.set_script(plane_script)
	current_vehicle = "plane"