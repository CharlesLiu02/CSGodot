extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_label = $CanvasLayer/HUD/HealthLabel
@onready var lives_label = $CanvasLayer/HUD/LivesLabel
@onready var ammo_label = $CanvasLayer/HUD/AmmoLabel

const T_player = preload("res://t_player.tscn")
const smoke_grenade = preload("res://smoke_grenade.tscn")
const frag_grenade = preload("res://frag_grenade.tscn")
const bullet_wake_scene = preload("res://smoke/bullet_wake.tscn")
const PORT = 9999 # Port for server to live on
var enet_peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_t_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_t_player(multiplayer.get_unique_id())
	
	#upnp_setup()

func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_t_player(peer_id):
	var t_player = T_player.instantiate()
	t_player.name = str(peer_id)
	# Add to scene tree
	add_child(t_player)
	if t_player.is_multiplayer_authority():
		t_player.health_changed.connect(update_health)
		t_player.lives_decreased.connect(update_lives)
		t_player.ammo_changed.connect(update_ammo)
	
func update_health(health_value):
	health_label.text = "Health: " + str(health_value)
	
func update_lives(lives):
	if lives <= 0:
		lives_label.text = "YOU ARE DEAD"
	else:
		lives_label.text = "Lives: " + str(lives)
		
func update_ammo(ammo):
	ammo_label.text = "Ammo: " + str(ammo)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

# add "call_local" so that server can also spawn grenade
@rpc("any_peer", "call_local")
func throw_grenade(selected_grenade, grenade_toss_pos_transform):
	var selected_scene
	if selected_grenade == "smoke":
		selected_scene = smoke_grenade
	else:
		selected_scene = frag_grenade
	var grenade = selected_scene.instantiate()
	
	add_child(grenade, true)
	grenade.global_transform = grenade_toss_pos_transform
	grenade.apply_impulse(-grenade.global_transform.basis.z * 10.0)
	
@rpc("any_peer", "call_local")
func create_bullet_wake(from, hit_position):
	var wake = bullet_wake_scene.instantiate()
	add_child(wake, true)
	wake.global_position = (from + hit_position) / 2
	wake.look_at(hit_position)
	wake.set_length(from.distance_to(hit_position))

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health)
		node.lives_decreased.connect(update_lives)
		node.ammo_changed.connect(update_ammo)

# Play online
func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discover Failed! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")
	
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
