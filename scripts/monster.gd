extends Area2D

@export var speed = 20.0
@export var health = 100
@export var damage = 10
@export var attack_interval = 1.0

@export var single_frame_texture: Texture2D  # for the particle effect

var attack_timer = 0.0
var target_human: Area2D
var is_attacking = false
var is_dead = false   # Track if death sequence has already happened
var current_row: int = -1  # Track the row the monster is in

func _ready():
	add_to_group("Monsters")
	$AnimationPlayer.play("walk_left")  # Loopable animation is okay

	# Determine which row the monster is in based on its position
	current_row = int(position.y / 32)

	# Ensure no duplicate connections
	if is_connected("area_entered", Callable(self, "_on_Monster_area_entered")):
		disconnect("area_entered", Callable(self, "_on_Monster_area_entered"))
	connect("area_entered", Callable(self, "_on_Monster_area_entered"))

func _process(delta):
	if is_dead:
		return  # Skip all movement/attacks if monster is already dying or dead

	if is_attacking:
		if not is_instance_valid(target_human):
			is_attacking = false
			speed = 20
			$AnimationPlayer.play("walk_left")
		else:
			attack_timer += delta
			if attack_timer >= attack_interval:
				attack_timer = 0
				target_human._take_damage(damage)
	else:
		position.x -= speed * delta  # Continue moving left

func _on_Monster_area_entered(area: Area2D):
	if is_dead:
		return

	# Only stop if the human unit is in the same row
	if area.is_in_group("Humans") and int(area.position.y / 32) == current_row:
		target_human = area
		speed = 0
		is_attacking = true
		switch_to_random_attack()

func switch_to_random_attack():
	var attacks = ["attack_1_left", "attack_2_left", "attack_3_left"]
	var rnd = randi() % attacks.size()
	$AnimationPlayer.play(attacks[rnd])

func _take_damage(amount):
	if is_dead:
		return  # Already dying, ignore further damage
	health -= amount

	if health <= 0:
		is_dead = true  # Mark that the death sequence has started

		# 1) Play death animation (ensure "death_left" is NOT looped)
		$AnimationPlayer.play("death_left")
		await $AnimationPlayer.animation_finished

		# 2) Start the pixel explosion (single-frame texture),
		#    then fade out the sprite as the effect plays.
		if single_frame_texture:
			$DeathParticles.initialize(single_frame_texture)
		$DeathParticles.emitting = true

		var effect_duration = $DeathParticles.duration
		var fade_tween = create_tween()
		fade_tween.tween_property($Sprite2D, "modulate:a", 0.0, effect_duration)
		await fade_tween.finished

		# 3) Clean up monster (and child particles).
		queue_free()
