# Scripts/GameManager.gd
extends Node

var resources = 100

func can_afford(cost):
	return resources >= cost

func spend(cost):
	if can_afford(cost):
		resources -= cost
		return true
	return false
