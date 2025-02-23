extends Area2D

@export var resource_value = 1000  
@export var float_range: float = 20  # How far the goo moves
@export var float_speed: float = 1.5  # Speed of floating
@export var lifespan: float = 10  # Time before Goo disappears

@onready var sprite = $Sprite2D  

func _ready():
	add_to_group("Goo")
	monitoring = true
	connect("input_event", Callable(self, "_on_input_event"))  

	# Start floating animation
	start_floating()

	# Remove the goo after lifespan ends
	get_tree().create_timer(lifespan).timeout.connect(queue_free)

func start_floating():
	# Random initial offset direction
	var x_offset = randf_range(-float_range, float_range)
	var y_offset = randf_range(-float_range, float_range)
	var target_position = position + Vector2(x_offset, y_offset)

	# Ensure the Goo stays within screen boundaries
	var viewport = get_viewport_rect().size
	target_position.x = clamp(target_position.x, 0, viewport.x)
	target_position.y = clamp(target_position.y, 0, viewport.y)

	# Create a new tween every time to prevent errors
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Tween movement
	tween.tween_property(self, "position", target_position, float_speed)
	tween.tween_callback(start_floating)  # Restart floating when tween completes

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		GameManager.resources += resource_value
		queue_free()

func on_mouse_entered():
	sprite.modulate = Color(1, 1, 0)  

func on_mouse_exited():
	sprite.modulate = Color(1, 1, 1)  

func on_clicked():
	sprite.modulate = Color(1, 0.5, 0.5)  
	await get_tree().create_timer(0.1).timeout  
	sprite.modulate = Color(1, 1, 1)  

	GameManager.resources += resource_value
	queue_free()
