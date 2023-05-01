extends RigidBody3D

@export var smoke_volume = preload("res://smoke/smoke_volume.tscn")



func _on_explode_timer_timeout():
	var smoke = smoke_volume.instantiate()
	get_parent().add_child(smoke)
	print(get_parent().get_children())
	smoke.global_position = global_position
	queue_free()
