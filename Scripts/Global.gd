extends Node

var Batteries = 0
var CoinSound = 0
var CheckpointPos = Vector3(0,0,0)
var DustTextures = [
	load("res://Textures/Dust/dust_0.png"),
	load("res://Textures/Dust/dust_1.png"),
	load("res://Textures/Dust/dust_2.png"),
	load("res://Textures/Dust/dust_3.png"),
]

func reload_current_level():
	get_tree().reload_current_scene()
