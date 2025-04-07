extends Node

@onready var timer: Timer = $Timer

const BREAK_OVERLAY = preload("res://scenes/break_overlay.tscn")
const BREAK_PARTICLES = preload("res://scenes/break_particles.tscn")

var ice_layer: TileMapLayer
var ice_cells: Array[Vector2i] = []
var ice_tile_health: Dictionary
var ice_tile_max_health: Dictionary
var ice_sound: AudioStreamPlayer2D
var main_node: Node

var current_row: int = 0

func _ready() -> void:
	timer.wait_time = Global.icedrill_time
	timer.one_shot = false
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if ice_cells.is_empty():
		return
	
	for col in range(9):
		var target_pos = Vector2i(col, current_row)
		
		if ice_layer.get_cell_tile_data(target_pos) != null and ice_tile_health.has(target_pos):
			var break_particles = BREAK_PARTICLES.instantiate()
			break_particles.position = ice_layer.map_to_local(target_pos)
			add_child(break_particles)
			
			if not main_node.existing_cracks.has(target_pos):
				var crack_overlay = BREAK_OVERLAY.instantiate()
				crack_overlay.position = ice_layer.map_to_local(target_pos)
				crack_overlay.tile_pos = target_pos
				crack_overlay.ice_health_data = ice_tile_health
				crack_overlay.max_health = ice_tile_max_health.get(target_pos, 1)
				main_node.add_child(crack_overlay)
				main_node.existing_cracks[target_pos] = crack_overlay
			
			if ice_sound:
				ice_sound.pitch_scale = randf_range(0.9, 1.0)
				ice_sound.play()
			
			ice_tile_health[target_pos] -= Global.icedrill_hit
			
			if ice_tile_health[target_pos] <= 0:
				main_node.ice_amount += 1
				ice_cells.erase(target_pos)
				ice_tile_health.erase(target_pos)
				if main_node.existing_cracks.has(target_pos):
					main_node.existing_cracks[target_pos].queue_free()
					main_node.existing_cracks.erase(target_pos)
	
	ice_layer.clear()
	ice_layer.set_cells_terrain_connect(ice_cells, 0, 0, true)
	
	current_row += 1
	if current_row > 12:
		current_row = 0
