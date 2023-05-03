extends RigidBody3D

@export var inverse_smoke = preload("res://smoke/inverse_smoke.tscn")

func _on_explode_timer_timeout():
	var desmoke = inverse_smoke.instantiate()
	get_parent().add_child(desmoke)
	desmoke.global_position = global_position
	queue_free()
