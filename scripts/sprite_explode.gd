extends GPUParticles2D

@export var duration := 1.0
# This duration determines how long we fade out the monster sprite.

func _ready():
	# Emit particles only once, then stop automatically.
	one_shot = true
	# Not emitting until triggered by monster.gd
	emitting = false

	# CRITICAL: Force local coordinates so swirl remains
	# around the monster, not the entire screen.
	local_coords = true

func initialize(sprite: Texture2D):
	# If there's no sprite, do nothing.
	if not sprite:
		return

	var mat = process_material as ShaderMaterial
	if mat:
		# Dynamically size the emission box to half the sprite's width/height
		var half_w = float(sprite.get_width()) * 0.5
		var half_h = float(sprite.get_height()) * 0.5
		mat.set_shader_parameter("emission_box_extents", Vector3(half_w, half_h, 1.0))
		mat.set_shader_parameter("sprite", sprite)

	# Set total particle amount = sprite width * sprite height
	# so each pixel can "explode" individually.
	amount = sprite.get_width() * sprite.get_height()
