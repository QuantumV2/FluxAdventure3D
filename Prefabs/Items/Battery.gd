extends Node3D

func _on_area_3d_area_entered(area):
	if(area.name == "PlayerArea"):
		Global.CoinSound.play() 
		Global.Batteries += 1
		queue_free()
