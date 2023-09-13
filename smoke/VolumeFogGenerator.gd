extends Node3D

@export var voxel_size := 1.0
@export var smoke_volume = preload("res://smoke/smoke_volume.tscn")

var sphere_radius = 5
var queue = []
var seen = []
var num_smoke = 0
var max_smoke = 200
var max_volume = 200
var max_spawn_per_frame = 10
var volume = 0
var directions = [Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1), Vector3(-1, 0, 0), Vector3(0, -1, 0), Vector3(0, 0, -1)]

func _ready():
	# Create the initial voxel at the center
	create_volume(Vector3.ZERO)
	queue.clear()
	queue_append_neighbors(Vector3.ZERO)
	seen.clear()
	seen.append(Vector3.ZERO)

func _process(delta):
	if volume < max_volume:
		start_build_layer()

func queue_append_neighbors(pos):
	for dir in directions:
		if not is_occupied(pos+dir) and not pos+dir in seen and not pos+dir in queue:
			queue.append(pos+dir)

func start_build_layer():
	var num_spawned_frame = 0
	# Continue to spawn smokes under the conditions that:
	# - there are still items in the queue
	# - we haven't reached the max_smoke limit yet
	# - we haven't exceeded the max spawn per fram yet
	while(queue.size() > 0 and max_smoke > num_smoke and max_spawn_per_frame > num_spawned_frame):
		queue.sort_custom(func(a, b): return a.length() < b.length())
		var pos = queue.pop_front();
		if round(pos.length()) <= sphere_radius:
			num_smoke += 1
			num_spawned_frame += 1
			create_volume(pos)
			seen.append(pos)
			queue_append_neighbors(pos)


func create_volume(pos: Vector3):
	var v = smoke_volume.instantiate()
	add_child(v)
	v.position = pos
	volume += 1

func is_occupied(pos: Vector3) -> bool:
	var state = get_world_3d().direct_space_state
	var query = PhysicsPointQueryParameters3D.new()
	query.position = global_transform * pos
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = state.intersect_point(query)
	
	if result:
		return true
	else:
		return false
