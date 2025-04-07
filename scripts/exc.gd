extends Node

@onready var timer: Timer = $Timer

const ORE_PARTICLES = preload("res://scenes/ore_particles.tscn")

var ice_layer: TileMapLayer
var ore_layer: TileMapLayer
var ice_cells: Array[Vector2i] = []
var ore_cells: Array[Vector2i] = []
var ore_tile_health: Dictionary
var ice_sound: AudioStreamPlayer2D
var main_node: Node

var current_row: int = -1

func _ready() -> void:
	timer.wait_time = Global.excavator_time
	timer.one_shot = false
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	select_random_row()

func select_random_row() -> void:
	if ore_cells.is_empty():
		return
	
	var available_rows: Array[int] = []
	for cell in ore_cells:
		if not available_rows.has(cell.y):
			available_rows.append(cell.y)
	
	if available_rows.is_empty():
		current_row = randi_range(0, 11)
	else:
		current_row = available_rows[randi_range(0, available_rows.size() - 1)]

func _on_timer_timeout() -> void:
	if current_row == -1:
		return
	
	for col in range(8):
		var target_pos = Vector2i(col, current_row)
		
		if not ice_layer.get_cell_tile_data(target_pos):
			if ore_layer.get_cell_tile_data(target_pos) != null and ore_tile_health.has(target_pos):
				var ore_particles = ORE_PARTICLES.instantiate()
				ore_particles.position = ore_layer.map_to_local(target_pos)
				add_child(ore_particles)
				
				if ice_sound:
					ice_sound.pitch_scale = randf_range(0.9, 1.0)
					ice_sound.play()
				
				ore_tile_health[target_pos] -= Global.excavator_hit
				
				if ore_tile_health[target_pos] <= 0:
					var tile_data = ore_layer.get_cell_atlas_coords(target_pos)
					if tile_data.y == 1:
						match tile_data.x:
							0:
								main_node.coal_amount += 25
							1:
								main_node.coal_amount += 5
							2:
								main_node.coal_amount += 1
					elif tile_data.y == 2:
						match tile_data.x:
							0:
								main_node.iron_amount += 25
							1:
								main_node.iron_amount += 5
							2:
								main_node.iron_amount += 1
					elif tile_data.y == 3:
						match tile_data.x:
							0:
								main_node.gold_amount += 25
							1:
								main_node.gold_amount += 5
							2:
								main_node.gold_amount += 1
					ore_cells.erase(target_pos)
					ore_tile_health.erase(target_pos)
					ore_layer.erase_cell(target_pos)
					if ore_tile_health.is_empty():
						main_node.reset_data()
						main_node.update_tiles()
	
	select_random_row()
