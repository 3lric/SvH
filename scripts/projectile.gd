extends Area2D

@export var speed = 150.0
var trail_length = 10

func _process(delta):
		# Add the current position to the Line2D
	
	# Limit the number of points to keep the trail short

	position.x += speed * delta
	# Free projectile if it goes off-screen
	if position.x > 1000:
		queue_free()


func _on_Projectile_area_entered(area: Area2D) -> void:
	if area.is_in_group("Monsters"):
		area._take_damage(20)  # or appropriate damage
		queue_free()
