extends Node


func _on_area_3d_area_entered(area):
	if(area.name == "PlayerArea"):
		area.get_parent().global_position = Global.CheckpointPos
