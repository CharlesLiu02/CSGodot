extends RigidBody3D

@export var inverse_smoke = preload("res://smoke/inverse_smoke.tscn")
@onready var audio_player_dunk = $DunkAudioStreamPlayer3D

func _on_explode_timer_timeout():
	audio_player_dunk.play()
	var inv_smoke = inverse_smoke.instantiate()
	get_parent().add_child(inv_smoke)
	inv_smoke.global_position = global_position
	visible = false


func _on_dunk_stream_player_3d_finished():
	queue_free()
