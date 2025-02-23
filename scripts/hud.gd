extends CanvasLayer

@onready var resource_label = $Label

var slime_buttons = {}  
var selected_slime = "slime_basic"  

@export var slime_basic_image: Texture2D
@export var slime_normal_image: Texture2D

var slimes = {
	"slime_basic": {
		"scene": preload("res://scenes/slime_basic.tscn"),
		"cost": 100
	},
	"slime_normal": {
		"scene": preload("res://scenes/slime_normal.tscn"),
		"cost": 150
	}
}

func _ready():
	_create_slime_selection_ui()
	_update_selection_highlight()

func _process(delta):
	resource_label.text = "Resources: " + str(GameManager.resources)

func _create_slime_selection_ui():
	var screen_width = get_viewport().get_visible_rect().size.x

	var hbox = HBoxContainer.new()
	hbox.name = "SlimeSelection"
	hbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.position = Vector2(screen_width / 2 - 100, 10)
	add_child(hbox)

	var slime_images = {
		"slime_basic": slime_basic_image,
		"slime_normal": slime_normal_image
	}

	for slime_name in slimes.keys():
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		var texture_rect = TextureRect.new()
		texture_rect.texture = slime_images.get(slime_name, null)
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.custom_minimum_size = Vector2(40, 40)
		vbox.add_child(texture_rect)

		var button = Button.new()
		button.text = "Cost: " + str(slimes[slime_name]["cost"])
		button.name = slime_name
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.focus_mode = Control.FOCUS_NONE  
		button.mouse_filter = Control.MOUSE_FILTER_STOP  
		button.connect("pressed", Callable(self, "_on_slime_selected").bind(slime_name))
		vbox.add_child(button)

		hbox.add_child(vbox)
		slime_buttons[slime_name] = {"button": button, "image": texture_rect}

	_update_selection_highlight()

func _on_slime_selected(slime_name):
	selected_slime = slime_name
	_update_selection_highlight()

	var board = get_tree().current_scene.get_node_or_null("Board")
	if board:
		board.selected_human_scene = slimes[slime_name]["scene"]
		print("Updated selected_human_scene to:", slime_name)

	if slime_name == "slime_basic":
		Input.action_press("slime_1")
		Input.action_release("slime_1")
	elif slime_name == "slime_normal":
		Input.action_press("slime_2")
		Input.action_release("slime_2")

func _update_selection_highlight():
	for slime_name in slime_buttons.keys():
		if slime_name == selected_slime:
			slime_buttons[slime_name]["button"].modulate = Color(1, 1, 0)
		else:
			slime_buttons[slime_name]["button"].modulate = Color(1, 1, 1)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = event.position  
		var hud_rect = Rect2(Vector2(0, 0), Vector2(get_viewport().get_visible_rect().size.x, 60))

		# **Stop event from reaching Board.gd**
		if hud_rect.has_point(mouse_pos):
			print("HUD clicked, no slime placed.")
			get_viewport().set_input_as_handled()
			return  

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			_on_slime_selected("slime_basic")
		elif event.keycode == KEY_2:
			_on_slime_selected("slime_normal")
