extends ColorRect

@export var rows: int = 5
@export var columns: int = 9
@export var cell_size: Vector2 = Vector2(32, 32)

func _ready():
	queue_redraw()

func _draw():
	var color1 = Color(0.3, 0.3, 0.3, 0.4)  # Light gray
	var color2 = Color(0.5, 0.5, 0.5, 0.4)  # Darker gray
	var path_color = Color(1.0, 0.1, 0.1, 0.5)  # Red for enemy path
	var middle_row = int(rows / 2)

	for r in range(rows):
		for c in range(columns):
			var rect = Rect2(Vector2(c * cell_size.x, r * cell_size.y), cell_size)
			
			# Alternate colors
			var current_color = color1 if (r + c) % 2 == 0 else color2
			if r == middle_row:
				current_color = path_color  # Highlight enemy path

			draw_rect(rect, current_color, true)
