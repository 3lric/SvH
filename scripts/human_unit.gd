extends Area2D

@export var cost = 100  # Resource cost to place the unit
@export var health = 100  # Unit health
@export var attack_power = 20  # Damage dealt per attack
@export var attack_cooldown = 1.0  # Time between attacks
@export var goo_interval = 5.0  # Time between Goo drops
@export var drops_goo = false  # Whether this unit drops Goo
@export var can_attack = true  # Whether this unit can attack

var attack_timer = 0.0
var goo_timer = 0.0
var current_row: int = -1  # Store the row the slime is in

@onready var sprite = $Sprite2D  # Reference to the Sprite2D node
@onready var custom_material = sprite.material as ShaderMaterial  # Explicitly cast to ShaderMaterial

func _ready():
	add_to_group("Humans")  # Add this unit to the Humans group
	monitoring = true
	monitorable = true
	current_row = int(position.y / 32)  # Determine row based on position

	# Start with the sprite fully exploded
	custom_material.set("shader_param/time", 0.0)
	_start_assembly_animation()

func _process(delta):
	if can_attack:
		attack_timer += delta
		if attack_timer >= attack_cooldown:
			attack_timer = 0
			_attack()

	if drops_goo:
		goo_timer += delta
		if goo_timer >= goo_interval:
			goo_timer = 0
			_drop_goo()

func _attack():
	var target_enemy = _find_enemy_in_row()
	if target_enemy:
		var projectile_scene = preload("res://scenes/projectile.tscn")
		var projectile = projectile_scene.instantiate()
		projectile.position = position

		# Instead of assigning `direction`, call a method on the projectile
		if projectile.has_method("set_target"):
			projectile.set_target(target_enemy.position)

		get_parent().add_child(projectile)

func _find_enemy_in_row():
	# Check for enemies in the same row
	for enemy in get_tree().get_nodes_in_group("Monsters"):
		if int(enemy.position.y / 32) == current_row:
			return enemy
	return null

func _drop_goo():
	var goo_scene = preload("res://scenes/goo.tscn")
	var goo = goo_scene.instantiate()
	goo.position = position + Vector2(0, 16)  # Offset below the slime
	get_parent().add_child(goo)

func _start_assembly_animation():
	# Animate the time parameter from 0.0 to 1.0
	for i in range(11):
		await get_tree().create_timer(0.1).timeout
		custom_material.set("shader_param/time", i / 10.0)

func _take_damage(damage):
	health -= damage
	if health <= 0:
		queue_free()
