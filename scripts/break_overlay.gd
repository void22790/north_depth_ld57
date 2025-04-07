extends Sprite2D

var tile_pos: Vector2i
var ice_health_data: Dictionary
var parent_layer: TileMapLayer
var max_health

func _process(delta: float) -> void:
	if not ice_health_data.has(tile_pos):
		queue_free()
		return
	
	var current_health = ice_health_data[tile_pos]
	if current_health <= 0:
		queue_free()
		return
	
	var percent = float(current_health) / float(max_health) * 100.0
	
	if percent >= 90:
		frame_coords.x = 0
	elif percent >= 80 and percent < 90:
		frame_coords.x = 1
	elif percent >= 70 and percent < 80:
		frame_coords.x = 2
	elif percent >= 60 and percent < 70:
		frame_coords.x = 3
	elif percent >= 50 and percent < 60:
		frame_coords.x = 4
	elif percent >= 40 and percent < 50:
		frame_coords.x = 5
	elif percent >= 30 and percent < 40:
		frame_coords.x = 6
	elif percent >= 20 and percent < 30:
		frame_coords.x = 7
	elif percent >= 10 and percent < 20:
		frame_coords.x = 8
