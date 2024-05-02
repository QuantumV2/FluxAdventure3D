extends Node

var Batteries = 0
var CoinSound = 0
var CheckpointPos = Vector3(0,0,0)

func reload_current_level():
	get_tree().reload_current_scene()
