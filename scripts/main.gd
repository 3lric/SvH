# Scripts/Main.gd
extends Node2D

func _ready():
	print("Game Started: Main Scene Ready")
	var hud_scene = preload("res://scenes/hud.tscn")
	var hud = hud_scene.instantiate()
	add_child(hud)
