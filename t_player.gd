
extends CharacterBody3D

signal health_changed(health_value)

# Movement Parameters
@export var speed = 6
@export var acceleration = 15
@export var jump_velocity = 8
@export var smoke_grenade = preload("res://smoke_grenade.tscn")
@export var frag_grenade = preload("res://frag_grenade.tscn")
var look_sensitivity = 0.0005
var gravity = 25
var curr_velocity = 0
var curr_velocity_y = 0
var is_dead = false
var is_reloading = false
@onready var camera = $Camera3D
@onready var muzzle_flash = $Camera3D/t_model/MuzzleFlash
@onready var grenade_toss_pos = $GrenadeTossPos
@onready var selected_grenade = smoke_grenade

var health = 100

# Weapon Parameters
@onready var animation_player = $Camera3D/t_model/AnimationPlayer
@onready var raycast = $Camera3D/RayCast3D

func _enter_tree():
	# Make sure each client controls their own player
	set_multiplayer_authority(str(name).to_int())

# Movement functions
func _physics_process(delta):
	if is_dead or not is_multiplayer_authority():
		return
	
	var direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction = direction.normalized()
	curr_velocity = velocity.lerp(direction * speed, acceleration * delta)
	
	# Handle jumping
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			curr_velocity_y = jump_velocity
	else: 
		curr_velocity_y -= gravity * delta
	
	velocity = curr_velocity
	velocity.y = curr_velocity_y
	move_and_slide()
	
	# Toggle mouse
	if Input.is_action_just_pressed("ui_cancel"): 
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

func _input(event):
	if is_dead or not is_multiplayer_authority():
		return
	check_animation()
	
	if event.is_action_pressed("throw_grenade"):
		throw_grenade()
		
	if event.is_action_pressed("item_1"):
		selected_grenade = smoke_grenade
		
	if event.is_action_pressed("item_2"):
		selected_grenade = frag_grenade
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		# Make sure grenade toss position changes with camera
		grenade_toss_pos.rotate_x(-event.relative.y * look_sensitivity)
		grenade_toss_pos.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func check_animation():
	muzzle_flash.emitting = false
	if Input.is_action_pressed("fire"):
		fire()
	elif Input.is_action_pressed("reload"):
		reload()
		is_reloading = true
	elif Input.is_action_pressed("death"):
		death()
		is_dead = true

# Weapon Fire functions
func fire():
	if is_reloading:
		return
	muzzle_flash.restart()
	muzzle_flash.emitting = true
	if raycast.is_colliding():
		var hit_player = raycast.get_collider()
		# Make other player take damage
		hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
		
func throw_grenade():
	var grenade = selected_grenade.instantiate()
	
	get_tree().root.add_child(grenade)
	grenade.global_transform = grenade_toss_pos.global_transform
	grenade.apply_impulse(-grenade.global_transform.basis.z * 8.0)

func reload():
	animation_player.play("rifle_reload001")
	
func death():
	is_dead = true
	animation_player.play("deathpose_lowviolence")
	
func _on_finished(animation):
	if animation == "rifle_reload001":
		is_reloading = false
	if animation == "deathpose_lowviolence":
		health = 100
		is_dead = false
		position = Vector3(0, 1, 0)
		# Reset animation to default
		animation_player.play("rifle_reload001")
		animation_player.stop()
		health_changed.emit(health)
	
func _ready():
	if not is_multiplayer_authority():
		return
	camera.current = true
	animation_player.connect("animation_finished", _on_finished)
	
@rpc("any_peer")
func receive_damage():
	health -= 33
	if health <= 0:
		health = 0
		death()
	health_changed.emit(health)
	
	
