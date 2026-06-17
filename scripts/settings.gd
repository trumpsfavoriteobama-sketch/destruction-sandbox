extends Node3D

# Settings and configuration

var graphics_quality = "high"
var mouse_sensitivity = 0.003
var master_volume = 1.0
var vehicle_ammo = {
	"tank": 50,
	"plane": 20
}

func _ready() -> void:
	print("Settings initialized")
