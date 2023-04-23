
extends CharacterBody3D

# Movement Parameters
@export var speed = 6
@export var acceleration = 15
@export var jump_velocity = 8
var look_sensitivity = 0.0005
var gravity = 25
var curr_velocity = 0
var curr_velocity_y = 0
@onready var camera:Camera3D = $Camera3D
@onready var muzzle_flash = $Camera3D/weapon/MuzzleFlash

# Weapon Parameters
var ak_damage = 33
#@onready var player = $AnimationPlayer
@onready var weapon = $Camera3D/weapon/AnimationPlayer
@onready var raycast = $Camera3D/RayCast3D

# Movement functions
func _physics_process(delta):
	fire()
	reload()
	
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
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

# Weapon Fire functions
func fire():
	if Input.is_action_pressed("fire"):
		weapon.play("fire")
		muzzle_flash.restart()
		muzzle_flash.emitting = true
	else:
		muzzle_flash.emitting = false
		
func reload():
	if Input.is_action_pressed("reload"):
		weapon.play("reload")
