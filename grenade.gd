extends RigidBody3D

@export var smoke_volume = preload("res://smoke/smoke_volume.tscn")
@export var square_smoke_volume = preload("res://smoke/square_smoke_volume.tscn")



func _on_explode_timer_timeout():
	var smoke = square_smoke_volume.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	queue_free()
