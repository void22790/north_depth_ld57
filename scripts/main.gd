extends Node2D

# Tile References
@onready var bg_layer: TileMapLayer = $BgLayer
@onready var ore_layer: TileMapLayer = $OreLayer
@onready var ice_layer: TileMapLayer = $IceLayer

# Sound References
@onready var ice_sound: AudioStreamPlayer2D = $Sounds/IceSound
@onready var sounds: Node = $Sounds

# GUI References
@onready var depth_number: Label = $ControlNumbers/DepthNumber
@onready var max_depth_number: Label = $ControlNumbers/MaxDepthNumber
@onready var ice_number: Label = $ControlNumbers/IceNumber
@onready var coal_number: Label = $ControlNumbers/CoalNumber
@onready var iron_number: Label = $ControlNumbers/IronNumber
@onready var gold_number: Label = $ControlNumbers/GoldNumber
@onready var elevator_button: Button = $MainScreen/ElevatorButton
@onready var geo_center_button: Button = $MainScreen/GeoCenterButton
@onready var main_building_button: Button = $MainScreen/MainBuildingButton
@onready var barracks_button: Button = $MainScreen/BarracksButton
@onready var chp_button: Button = $MainScreen/CHPButton
@onready var ri_button: Button = $MainScreen/RIButton

# Building GUI References
@onready var building_gui: Node2D = $BuildingGUI
@onready var main_building: Node2D = $BuildingGUI/MainBuilding
@onready var button_buy_barracks: Button = $BuildingGUI/MainBuilding/ButtonBuyBarracks
@onready var button_buy_elevator: Button = $BuildingGUI/MainBuilding/ButtonBuyElevator
@onready var button_buy_geo: Button = $BuildingGUI/MainBuilding/ButtonBuyGeo
@onready var button_buy_chp: Button = $BuildingGUI/MainBuilding/ButtonBuyCHP
@onready var button_buy_lab: Button = $BuildingGUI/MainBuilding/ButtonBuyLab

@onready var barracks: Node2D = $BuildingGUI/Barracks
@onready var worker_amount: Label = $BuildingGUI/Barracks/WorkerAmount
@onready var mecha_amount: Label = $BuildingGUI/Barracks/MechaAmount
@onready var ice_drill_amount: Label = $BuildingGUI/Barracks/IceDrillAmount

@onready var geo: Node2D = $BuildingGUI/Geo
@onready var digger_amount: Label = $BuildingGUI/Geo/DiggerAmount
@onready var exc_amount: Label = $BuildingGUI/Geo/ExcAmount
@onready var tnt_amount: Label = $BuildingGUI/Geo/TNTAmount

@onready var chp: Node2D = $BuildingGUI/CHP
@onready var worker_level: Label = $BuildingGUI/CHP/WorkerLevel
@onready var mecha_level: Label = $BuildingGUI/CHP/MechaLevel
@onready var ice_drill_level: Label = $BuildingGUI/CHP/IceDrillLevel
@onready var upgrade_worker_button: Button = $BuildingGUI/CHP/UpgradeWorkerButton
@onready var upgrade_mecha_button: Button = $BuildingGUI/CHP/UpgradeMechaButton
@onready var upgrade_ice_drill_button: Button = $BuildingGUI/CHP/UpgradeIceDrillButton

@onready var lab: Node2D = $BuildingGUI/Lab
@onready var upgrade_digger_button: Button = $BuildingGUI/Lab/UpgradeDiggerButton
@onready var upgrade_exc_button: Button = $BuildingGUI/Lab/UpgradeExcButton
@onready var upgrade_tnt_button: Button = $BuildingGUI/Lab/UpgradeTNTButton
@onready var digger_level_amount: Label = $BuildingGUI/Lab/DiggerLevelAmount
@onready var exc_level_amount: Label = $BuildingGUI/Lab/ExcLevelAmount
@onready var tnt_level_amount: Label = $BuildingGUI/Lab/TNTLevelAmount

@onready var elevator: Node2D = $BuildingGUI/Elevator
@onready var upgrade_elevator: Button = $BuildingGUI/Elevator/UpgradeElevator
@onready var back_elevator_button: Button = $BuildingGUI/Elevator/BackElevatorButton
@onready var curr_max_depth: Label = $BuildingGUI/Elevator/CurrMaxDepth

@onready var button_sound: AudioStreamPlayer2D = $Sounds/ButtonSound
@onready var switch_sound: AudioStreamPlayer2D = $Sounds/SwitchSound

const BREAK_OVERLAY = preload("res://scenes/break_overlay.tscn")
const BREAK_PARTICLES = preload("res://scenes/break_particles.tscn")
const ORE_PARTICLES = preload("res://scenes/ore_particles.tscn")

var click_damage = 1

var sound_on: bool
var music_on: bool

var depth = 100
var max_depth = 200

var ice_amount = 0
var coal_amount = 0
var iron_amount = 0
var gold_amount = 0

var ice_tile_health: Dictionary = {}
var ice_tile_max_health: Dictionary = {}
var ice_health = 1

var ore_tile_health: Dictionary = {}
var ore_health = 1

var init_coal_chance: float = 0.1
var init_iron_chance: float = 0.1
var init_gold_chance: float = 0.03
var coal_chance: float
var iron_chance: float
var gold_chance: float

var cols = 8
var rows = 12

var init_coords: Vector2i = Vector2i(1,1)
var current_coords: Vector2i
var source_id = 0

var bg_atlas: Vector2i = Vector2i.ZERO
var coal_atlas: Vector2i = Vector2i(0,1)
var iron_atlas: Vector2i = Vector2i(0,2)
var gold_atlas: Vector2i = Vector2i(0,3)

var ice_cells: Array[Vector2i] = []
var ore_cells: Array[Vector2i] = []
var existing_cracks: Dictionary = {} 

func _ready() -> void:
	update_tiles()

func _process(delta: float) -> void:
	depth_number.text = str(depth).pad_zeros(12)
	max_depth_number.text = str(max_depth).pad_zeros(12)
	ice_number.text = str(ice_amount).pad_zeros(16)
	coal_number.text = str(coal_amount).pad_zeros(16)
	iron_number.text = str(iron_amount).pad_zeros(16)
	gold_number.text = str(gold_amount).pad_zeros(16)
	worker_amount.text = str(Global.worker_amount)
	mecha_amount.text = str(Global.mecha_amount)
	ice_drill_amount.text = str(Global.icedrill_amount)
	digger_amount.text = str(Global.digger_amount)
	exc_amount.text = str(Global.excavator_amount)
	tnt_amount.text = str(Global.tnt_amount)
	worker_level.text = str(Global.worker_level)
	mecha_level.text = str(Global.mecha_level)
	ice_drill_level.text = str(Global.icedrill_level)
	digger_level_amount.text = str(Global.digger_level)
	exc_level_amount.text = str(Global.exc_level)
	tnt_level_amount.text = str(Global.tnt_level)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("LMB"):
		var mouse_pos = get_global_mouse_position()
		var tile_mouse_pos = ice_layer.local_to_map(mouse_pos)
		damage_tile(tile_mouse_pos)
		damage_ore(tile_mouse_pos)
		
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("ui_left"):
		ice_layer.hide()
		print(ore_tile_health.values())
	if Input.is_action_just_pressed("ui_right"):
		ice_layer.show()

func get_ore_amount(depth_amount: int) -> int:
	var r = randf()
	if depth_amount < 500:
		if r < 0.7:
			return 2
		elif r < 0.9:
			return 1
		else:
			return 0
	elif depth_amount < 1000:
		if r < 0.6:
			return 2
		elif r < 0.8:
			return 1
		else:
			return 0
	else:
		if r < 0.5:
			return 2
		elif r < 0.7:
			return 1
		else:
			return 0

func damage_tile(tile_position: Vector2i):
	if ice_layer.get_cell_tile_data(tile_position) == null:
		return 

	var break_particles = BREAK_PARTICLES.instantiate()
	break_particles.position = ice_layer.map_to_local(tile_position)
	add_child(break_particles)
	
	if not existing_cracks.has(tile_position):
		var crack_overlay = BREAK_OVERLAY.instantiate()
		crack_overlay.position = ice_layer.map_to_local(tile_position)
		crack_overlay.tile_pos = tile_position
		crack_overlay.ice_health_data = ice_tile_health
		crack_overlay.max_health = ice_tile_max_health[tile_position]
		add_child(crack_overlay)
		existing_cracks[tile_position] = crack_overlay
	
	ice_tile_health[tile_position] -= click_damage
	ice_sound.pitch_scale = randf_range(0.9, 1.0)
	ice_sound.play()
	if ice_tile_health[tile_position] <= 0:
		ice_amount += 1
		ice_cells.erase(tile_position)
		ice_tile_health.erase(tile_position)
		if existing_cracks.has(tile_position):
			existing_cracks[tile_position].queue_free()
			existing_cracks.erase(tile_position)
		ice_layer.clear()
		ice_layer.set_cells_terrain_connect(ice_cells, 0, 0, true)

func damage_ore(tile_position: Vector2i):
	if ore_layer.get_cell_tile_data(tile_position) == null:
		return
	if ice_layer.get_cell_tile_data(tile_position):
		return 
	if not ore_tile_health.has(tile_position):
		return
	var ore_particles = ORE_PARTICLES.instantiate()
	ore_particles.position = ice_layer.map_to_local(tile_position)
	add_child(ore_particles)
	ore_tile_health[tile_position] -= click_damage
	ice_sound.pitch_scale = randf_range(0.9, 1.0)
	ice_sound.play()
	if ore_tile_health[tile_position] <= 0:
		var tile_data = ore_layer.get_cell_atlas_coords(tile_position)
		if tile_data.y == 1:
			match tile_data.x:
				0:
					coal_amount += 25
				1:
					coal_amount += 5
				2: 
					coal_amount += 1
		elif tile_data.y == 2:
			match tile_data.x:
				0:
					iron_amount += 25
				1: 
					iron_amount += 5
				2:
					iron_amount += 1
		elif tile_data.y == 3:
			match tile_data.x:
				0:
					gold_amount += 25
				1: 
					gold_amount += 5
				2:
					gold_amount += 1
		ore_cells.erase(tile_position)
		ore_tile_health.erase(tile_position)
		ore_layer.erase_cell(tile_position)
		if ore_tile_health.is_empty():
			reset_data()
			update_tiles()

func get_ice_health(depth_amount: int) -> int:
	if depth_amount < 500:
		return 3
	elif depth_amount < 1000:
		return 5
	else:
		return 10

func get_ore_health(depth_amount: int) -> int:
	if depth_amount < 500:
		return 4
	elif depth_amount < 1000:
		return 6
	else:
		return 11

func _on_button_down_pressed() -> void:
	button_sound.play()
	if depth > 100:
		depth -= 100
		reset_data()
		update_tiles()
	if depth == 100:
		reset_data()
		update_tiles()

func _on_button_up_pressed() -> void:
	button_sound.play()
	if depth < max_depth:
		depth += 100
		reset_data()
		update_tiles()
	if depth == 1200:
		reset_data()
		update_tiles()

func _on_check_sound_toggled(toggled_on: bool) -> void:
	switch_sound.play()
	sound_on = toggled_on
	ice_sound.volume_db = 0 if sound_on else -80
	button_sound.volume_db = 0 if sound_on else -80
	switch_sound.volume_db = 0 if sound_on else -80

func _on_check_music_toggled(toggled_on: bool) -> void:
	switch_sound.play()
	music_on = toggled_on
	

func reset_data() -> void:
	ice_tile_health.clear()
	ice_tile_max_health.clear()
	ore_tile_health.clear()
	ice_cells.clear()
	ore_cells.clear()
	ore_layer.clear()
	ice_layer.clear()
	for crack in existing_cracks.values():
		crack.queue_free()
	existing_cracks.clear()

func update_tiles() -> void:
	for x in cols:
		for y in rows:
			current_coords = Vector2i(init_coords.x + x, init_coords.y + y)
			bg_layer.set_cell(current_coords, source_id, bg_atlas, 0)
			ore_cells.append(current_coords)
			ice_cells.append(current_coords)
			ice_tile_health[current_coords] = get_ice_health(depth)
			ice_tile_max_health[current_coords] = get_ice_health(depth)

	for i in ore_cells:
		if depth > 0 and depth < 500:
			coal_chance = init_coal_chance
			if randf() < coal_chance:
				coal_atlas = Vector2i(get_ore_amount(depth), 1)
				ore_layer.set_cell(i, source_id, coal_atlas, 0)
				ore_tile_health[i] = get_ore_health(depth)
		elif depth >= 500 and depth < 1000:
			coal_chance = 0.05
			iron_chance = init_iron_chance
			if randf() < coal_chance:
				coal_atlas = Vector2i(get_ore_amount(depth), 1)
				ore_layer.set_cell(i, source_id, coal_atlas, 0)
				ore_tile_health[i] = get_ore_health(depth)
			if randf() < iron_chance:
				if not ore_layer.get_cell_tile_data(i):
					iron_atlas = Vector2i(get_ore_amount(depth), 2)
					ore_layer.set_cell(i, source_id, iron_atlas, 0)
					ore_tile_health[i] = get_ore_health(depth)
		elif depth >= 1000 and depth < 1500:
			coal_chance = 0.01
			iron_chance = 0.07
			gold_chance = init_gold_chance
			if randf() < coal_chance:
				coal_atlas = Vector2i(get_ore_amount(depth), 1)
				ore_layer.set_cell(i, source_id, coal_atlas, 0)
				ore_tile_health[i] = get_ore_health(depth)
			if randf() < iron_chance:
				if not ore_layer.get_cell_tile_data(i):
					iron_atlas = Vector2i(get_ore_amount(depth), 2)
					ore_layer.set_cell(i, source_id, iron_atlas, 0)
					ore_tile_health[i] = get_ore_health(depth)
			if randf() < gold_chance:
				if not ore_layer.get_cell_tile_data(i):
					gold_atlas = Vector2i(get_ore_amount(depth), 3)
					ore_layer.set_cell(i, source_id, gold_atlas, 0)
					ore_tile_health[i] = get_ore_health(depth)

	ice_layer.set_cells_terrain_connect(ice_cells, 0, 0, true)

func disable_buttons() -> void:
	elevator_button.disabled = true
	geo_center_button.disabled = true
	main_building_button.disabled = true
	barracks_button.disabled = true
	chp_button.disabled = true
	ri_button.disabled = true

func enable_buttons() -> void:
	elevator_button.disabled = false
	geo_center_button.disabled = false
	main_building_button.disabled = false
	barracks_button.disabled = false
	chp_button.disabled = false
	ri_button.disabled = false

func _on_main_building_button_pressed() -> void:
	button_sound.play()
	disable_buttons()
	building_gui.show()
	main_building.show()

func _on_button_back_mb_pressed() -> void:
	button_sound.play()
	enable_buttons()
	building_gui.hide()
	main_building.hide()

func _on_button_buy_barracks_pressed() -> void:
	button_sound.play()
	if ice_amount >= 50 and coal_amount >= 20:
		ice_amount -= 50
		coal_amount -= 20
		button_buy_barracks.disabled = true
		barracks_button.show()

func _on_button_buy_elevator_pressed() -> void:
	button_sound.play()
	if ice_amount >= 1000 and coal_amount >= 100:
		ice_amount -= 1000
		coal_amount -= 100
		button_buy_elevator.disabled = true
		elevator_button.show()

func _on_button_buy_geo_pressed() -> void:
	button_sound.play()
	if ice_amount >= 2000 and coal_amount >= 150 and iron_amount >= 100:
		ice_amount -= 2000
		coal_amount -= 150
		iron_amount -= 100
		button_buy_geo.disabled = true
		geo_center_button.show()

func _on_button_buy_chp_pressed() -> void:
	button_sound.play()
	if ice_amount >= 5000 and coal_amount >= 500 and iron_amount >= 200 and gold_amount >= 100:
		ice_amount -= 5000
		coal_amount -= 500
		iron_amount -= 200
		gold_amount -= 100
		button_buy_chp.disabled = true
		chp_button.show()

func _on_button_buy_lab_pressed() -> void:
	button_sound.play()
	if ice_amount >= 10000 and coal_amount >= 1500 and iron_amount >= 800 and gold_amount >= 500:
		ice_amount -= 10000
		coal_amount -= 1500
		iron_amount -= 800
		gold_amount -= 500
		button_buy_lab.disabled = true
		ri_button.show()

func _on_barracks_button_pressed() -> void:
	button_sound.play()
	disable_buttons()
	building_gui.show()
	barracks.show()

func _on_button_back_barracks_pressed() -> void:
	button_sound.play()
	enable_buttons()
	building_gui.hide()
	barracks.hide()

func _on_button_buy_worker_pressed() -> void:
	button_sound.play()
	if ice_amount >= 40:
		ice_amount -= 40
		Global.worker_amount += 1
		var worker = preload("res://scenes/worker.tscn").instantiate()
		worker.ice_layer = ice_layer
		worker.ice_cells = ice_cells
		worker.ice_tile_health = ice_tile_health
		worker.ice_tile_max_health = ice_tile_max_health
		worker.ice_sound = ice_sound
		worker.main_node = self
		add_child(worker)

func _on_button_buy_mecha_pressed() -> void:
	button_sound.play()
	if ice_amount >= 800 and coal_amount >= 80:
		ice_amount -= 800
		coal_amount -= 80
		Global.mecha_amount += 1
		var mecha = preload("res://scenes/mecha.tscn").instantiate()
		mecha.ice_layer = ice_layer
		mecha.ice_cells = ice_cells
		mecha.ice_tile_health = ice_tile_health
		mecha.ice_tile_max_health = ice_tile_max_health
		mecha.ice_sound = ice_sound
		mecha.main_node = self
		add_child(mecha)

func _on_button_buy_ice_drill_pressed() -> void:
	button_sound.play()
	if ice_amount >= 3000 and coal_amount >= 250 and iron_amount >= 50:
		ice_amount -= 3000
		coal_amount -= 250
		iron_amount -= 50
		Global.icedrill_amount += 1
		var icedrill = preload("res://scenes/ice_drill.tscn").instantiate()
		icedrill.ice_layer = ice_layer
		icedrill.ice_cells = ice_cells
		icedrill.ice_tile_health = ice_tile_health
		icedrill.ice_tile_max_health = ice_tile_max_health
		icedrill.ice_sound = ice_sound
		icedrill.main_node = self
		add_child(icedrill)

func _on_geo_center_button_pressed() -> void:
	button_sound.play()
	disable_buttons()
	building_gui.show()
	geo.show()

func _on_button_back_geo_pressed() -> void:
	button_sound.play()
	enable_buttons()
	building_gui.hide()
	geo.hide()

func _on_button_buy_digger_pressed() -> void:
	button_sound.play()
	if iron_amount >= 50:
		iron_amount -= 50
		Global.digger_amount += 1
		var digger = preload("res://scenes/digger.tscn").instantiate()
		digger.ice_layer = ice_layer
		digger.ore_layer = ore_layer
		digger.ice_cells = ice_cells
		digger.ore_cells = ore_cells
		digger.ore_tile_health = ore_tile_health
		digger.ice_sound = ice_sound
		digger.main_node = self
		add_child(digger)

func _on_button_buy_exc_pressed() -> void:
	button_sound.play()
	if coal_amount >= 100 and iron_amount >= 100:
		coal_amount -= 100
		iron_amount -= 100
		Global.excavator_amount += 1
		var exc = preload("res://scenes/exc.tscn").instantiate()
		exc.ice_layer = ice_layer
		exc.ore_layer = ore_layer
		exc.ice_cells = ice_cells
		exc.ore_cells = ore_cells
		exc.ore_tile_health = ore_tile_health
		exc.ice_sound = ice_sound
		exc.main_node = self
		add_child(exc)

func _on_button_buy_tnt_pressed() -> void:
	button_sound.play()
	if coal_amount >= 1000 and iron_amount >= 200 and gold_amount >= 100:
		coal_amount -= 1000
		iron_amount -= 200
		gold_amount -= 100
		Global.tnt_amount += 1
		var tnt = preload("res://scenes/tnt.tscn").instantiate()
		tnt.ice_layer = ice_layer
		tnt.ore_layer = ore_layer
		tnt.ice_cells = ice_cells
		tnt.ore_cells = ore_cells
		tnt.ore_tile_health = ore_tile_health
		tnt.ice_sound = ice_sound
		tnt.main_node = self
		add_child(tnt)

func _on_chp_button_pressed() -> void:
	button_sound.play()
	disable_buttons()
	building_gui.show()
	chp.show()

func _on_chp_back_button_pressed() -> void:
	button_sound.play()
	enable_buttons()
	building_gui.hide()
	chp.hide()

func _on_upgrade_worker_button_pressed() -> void:
	button_sound.play()
	if Global.worker_time == 0.5:
		upgrade_worker_button.disabled = true
	if coal_amount >= 50:
		coal_amount -= 50
		Global.worker_level += 1
		Global.worker_time -= 0.5

func _on_upgrade_mecha_button_pressed() -> void:
	button_sound.play()
	if Global.mecha_hit == 5:
		upgrade_mecha_button.disabled = true
	if coal_amount >= 100 and iron_amount >= 50:
		coal_amount -= 100
		iron_amount -= 50
		Global.mecha_level += 1
		Global.mecha_hit += 1

func _on_upgrade_ice_drill_button_pressed() -> void:
	button_sound.play()
	if Global.icedrill_hit == 5:
		upgrade_ice_drill_button.disabled = true
	if ice_amount >= 9000 and coal_amount >= 950 and iron_amount >= 90:
		ice_amount -= 9000
		coal_amount -= 950
		iron_amount -= 90
		Global.icedrill_hit += 1
		Global.icedrill_level += 1

func _on_ri_button_pressed() -> void:
	button_sound.play()
	disable_buttons()
	building_gui.show()
	lab.show()

func _on_button_back_lab_pressed() -> void:
	button_sound.play()
	enable_buttons()
	building_gui.hide()
	lab.hide()

func _on_upgrade_digger_button_pressed() -> void:
	button_sound.play()
	if Global.digger_time <= 0.5:
		upgrade_digger_button.disabled = true
	if iron_amount >= 50:
		iron_amount -= 50
		Global.digger_level += 1
		Global.digger_time -= 0.5

func _on_upgrade_exc_button_pressed() -> void:
	button_sound.play()
	if Global.excavator_time <= 0.5:
		upgrade_exc_button.disabled = true
	if coal_amount >= 300 and gold_amount >= 50:
		coal_amount -= 300
		gold_amount -= 50
		Global.excavator_time -= 0.5
		Global.exc_level += 1

func _on_upgrade_tnt_button_pressed() -> void:
	button_sound.play()
	if Global.tnt_hit >= 5:
		upgrade_tnt_button.disabled = true
	if coal_amount >= 1000 and iron_amount >= 500 and gold_amount >= 105:
		coal_amount -= 1000
		iron_amount -= 500
		gold_amount -= 105
		Global.tnt_hit += 1
		Global.tnt_level += 1

func _on_elevator_button_pressed() -> void:
	button_sound.play()
	disable_buttons()
	building_gui.show()
	elevator.show()

func _on_back_elevator_button_pressed() -> void:
	button_sound.play()
	enable_buttons()
	building_gui.hide()
	elevator.hide()

func _on_upgrade_elevator_pressed() -> void:
	button_sound.play()
	if max_depth >= 1200:
		upgrade_elevator.disabled = true
	if iron_amount >= 100:
		iron_amount -= 100
		max_depth += 100
