extends CanvasLayer

# Main menu UI

var main_menu_open = true
var selected_weapon = "revolver"
var selected_vehicle = "none"

func _ready() -> void:
	draw_menu()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and not main_menu_open:
		show_pause_menu()

func draw_menu() -> void:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", preload("res://assets/menu_style.tres"))
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "DESTRUCTION SANDBOX"
	title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(title)
	
	# Weapon selection
	var weapon_label = Label.new()
	weapon_label.text = "SELECT WEAPON:"
	weapon_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(weapon_label)
	
	var weapons = ["revolver", "rocket_launcher"]
	for weapon in weapons:
		var btn = Button.new()
		btn.text = weapon.to_upper()
		btn.pressed.connect(_on_weapon_selected.bindv([weapon]))
		vbox.add_child(btn)
	
	# Vehicle selection
	var vehicle_label = Label.new()
	vehicle_label.text = "SELECT VEHICLE:"
	vehicle_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(vehicle_label)
	
	var vehicles = ["tank", "plane"]
	for vehicle in vehicles:
		var btn = Button.new()
		btn.text = vehicle.to_upper()
		btn.pressed.connect(_on_vehicle_selected.bindv([vehicle]))
		vbox.add_child(btn)
	
	# Start button
	var start_btn = Button.new()
	start_btn.text = "START GAME"
	start_btn.add_theme_font_size_override("font_size", 32)
	start_btn.pressed.connect(_on_start_game)
	vbox.add_child(start_btn)

func _on_weapon_selected(weapon: String) -> void:
	selected_weapon = weapon
	print("Selected weapon: ", weapon)

func _on_vehicle_selected(vehicle: String) -> void:
	selected_vehicle = vehicle
	print("Selected vehicle: ", vehicle)

func _on_start_game() -> void:
	main_menu_open = false
	for child in get_children():
		if child is PanelContainer:
			child.queue_free()
	
	print("Game started with weapon: ", selected_weapon, " and vehicle: ", selected_vehicle)

func show_pause_menu() -> void:
	print("Game paused")

func show_hud() -> void:
	# Ammo counter, weapon display, etc
	var hud_label = Label.new()
	hud_label.text = "Weapon: " + selected_weapon
	add_child(hud_label)