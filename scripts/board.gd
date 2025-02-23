# Scripts/Board.gd
extends Node2D

@export var rows: int = 5
@export var columns: int = 9
@export var cell_size: Vector2 = Vector2(32, 32)
@export var spawn_interval: float = 5.0

@export var monster_scene = preload("res://scenes/monster.tscn")
var selected_human_scene = preload("res://scenes/slime_basic.tscn")  # Default is Basic Slime

var lane_positions = []
var spawn_timer = 0.0
var grid_occupancy = {}  # Dictionary to track occupied slots
var slimes_by_row = {}  # Dictionary to track slimes in each row
var grid_overlay  # The ColorRect overlay

func _ready():
	_calculate_lane_positions()
	$GameCamera.make_current()
	_create_grid_overlay()

func _calculate_lane_positions():
	lane_positions.clear()
	for r in range(rows):
		var row_positions = []
		for c in range(columns):
			var x = c * cell_size.x + cell_size.x / 2
			var y = r * cell_size.y + cell_size.y / 2
			row_positions.append(Vector2(x, y))
		lane_positions.append(row_positions)

func _create_grid_overlay():
	grid_overlay = ColorRect.new()
	grid_overlay.name = "GridOverlay"
	grid_overlay.size = Vector2(columns * cell_size.x, rows * cell_size.y)
	grid_overlay.color = Color(1, 1, 1, 0)  # Fully transparent; we draw manually
	grid_overlay.z_index = -1  # Ensure it’s drawn below gameplay elements
	add_child(grid_overlay)

	grid_overlay.connect("draw", Callable(self, "_draw_grid"))
	grid_overlay.queue_redraw()

func _draw_grid():
	var color1 = Color(0.3, 0.3, 0.3, 0.4)
	var color2 = Color(0.5, 0.5, 0.5, 0.4)
	var path_color = Color(1.0, 0.1, 0.1, 0.5)
	var middle_row = int(rows / 2)

	for r in range(rows):
		for c in range(columns):
			var rect = Rect2(Vector2(c * cell_size.x, r * cell_size.y), cell_size)
			var current_color = color1 if (r + c) % 2 == 0 else color2
			if r == middle_row:
				current_color = path_color
			grid_overlay.draw_rect(rect, current_color, true)

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0
		spawn_monster()

func spawn_monster():
	var monster_types = [preload("res://scenes/monster_beholder_1.tscn")]
	var chosen_scene = monster_types[randi() % monster_types.size()]
	var monster = chosen_scene.instantiate()
	var middle_row = int(rows / 2)
	var last_col = columns - 1
	monster.position = lane_positions[middle_row][last_col]
	add_child(monster)

func _input(event):
	if event is InputEventKey and event.pressed:
		var key_pressed = event.as_text()
		if key_pressed == "1":
			selected_human_scene = preload("res://scenes/slime_basic.tscn")
		elif key_pressed == "2":
			selected_human_scene = preload("res://scenes/slime_normal.tscn")

	elif event is InputEventMouseButton and event.pressed:
		var world_pos = get_global_mouse_position()

		var space_state = get_world_2d().direct_space_state
		var query_params = PhysicsPointQueryParameters2D.new()
		query_params.position = world_pos
		query_params.collide_with_areas = true
		query_params.collide_with_bodies = true

		var results = space_state.intersect_point(query_params)
		for result in results:
			if result.collider.is_in_group("Goo"):
				result.collider.on_clicked()
				return

		var row = clamp(int(world_pos.y / cell_size.y), 0, rows - 1)
		var col = clamp(int(world_pos.x / cell_size.x), 0, columns - 1)
		var slot_key = str(row) + "_" + str(col)

		if grid_occupancy.has(slot_key):
			print("Slot already occupied!")
			return

		var human = selected_human_scene.instantiate()

		if not slimes_by_row.has(row):
			slimes_by_row[row] = []

		slimes_by_row[row].append(human)

		if GameManager.spend(human.cost):
			human.position = lane_positions[row][col]
			add_child(human)
			grid_occupancy[slot_key] = human

			human.connect("tree_exited", Callable(self, "_on_slime_removed").bind(slot_key, row, human))
			print("Placed", human.name, "at row =", row, ", col =", col)
		else:
			print("Not enough resources!")

func _on_slime_removed(slot_key, row, slime):
	grid_occupancy.erase(slot_key)
	if slimes_by_row.has(row) and slime in slimes_by_row[row]:
		slimes_by_row[row].erase(slime)
		if slimes_by_row[row].is_empty():
			slimes_by_row.erase(row)
