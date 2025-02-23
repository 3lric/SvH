# monster_stone_golem.gd (extends Area2D)
extends Area2D

@export var speed = 20.0
@export var health = 100
@export var damage = 10

var animation_player: AnimationPlayer

func _ready():
	# Assuming "AnimationPlayer" is a child node named "AnimationPlayer"
	animation_player = $AnimationPlayer
	animation_player.play("walk_left")

	# Add the monster to a group "Monsters"
	add_to_group("Monsters")

func _process(delta):
	# Movement logic
	position.x -= speed * delta

func switch_to_random_attack():
	var attacks = ["attack_1_left", "attack_2_left", "attack_3_left"]
	var random_attack = attacks[randi() % attacks.size()]
	animation_player.play(random_attack)

func _take_damage(amount):
	health -= amount
	if health <= 0:
		animation_player.play("dead_left")
		# Optionally wait for the "dead" anim to finish or queue_free() immediately
		queue_free()
