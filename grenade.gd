extends RigidBody3D

@export var smoke_volume = preload("res://smoke/smoke_volume.tscn")
@export var square_smoke_volume = preload("res://smoke/square_smoke_volume.tscn")
@onready var audio_player_smoke = $SmokeAudioStreamPlayer3D

func _on_explode_timer_timeout():
	audio_player_smoke.play()
	var smoke = square_smoke_volume.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	visible = false

func _on_smoke_audio_stream_player_3d_finished():
	queue_free()
