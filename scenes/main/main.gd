extends Node

var host: String
var port: int

var picked_fighter = "burial"
var sent = false

var multiplayer_peer = ENetMultiplayerPeer.new()
var spawn_point: Node3D

var f_burial = preload("res://scenes/player/classes/burial/burial.tscn")
var f_maestro = preload("res://scenes/player/classes/maestro/maestro.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if ("--server" in OS.get_cmdline_args() || OS.has_feature("dedicated_server")):
		print("starting server...")
		port = 6665
		multiplayer_peer.create_server(port)
		multiplayer.multiplayer_peer = multiplayer_peer
		
		print("spawining level...")
		add_level()
		
		multiplayer_peer.peer_disconnected.connect(func(id): destroy_player(id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayer_peer.get_connection_status() == multiplayer_peer.CONNECTION_CONNECTED and not sent:
		rpc("send_client_info", picked_fighter)
		sent = true

func _on_connect_button_pressed():
	if $Control/PanelContainer/VBoxContainer/AliasEdit.text != "":
		MpGlobals.my_alias = str($Control/PanelContainer/VBoxContainer/AliasEdit.text)
		port = str($Control/PanelContainer/VBoxContainer/PortLineEdit.text).to_int()
		host = str($Control/PanelContainer/VBoxContainer/IpLineEdit.text)
		multiplayer_peer.create_client(host, port)
		multiplayer.multiplayer_peer = multiplayer_peer
		$Control.visible = false

func _on_host_button_pressed():
	if $Control/PanelContainer/VBoxContainer/AliasEdit.text != "":
		MpGlobals.my_alias = str($Control/PanelContainer/VBoxContainer/AliasEdit.text)
		port = str($Control/PanelContainer/VBoxContainer/PortLineEdit.text).to_int()
		multiplayer_peer.create_server(port)
		multiplayer.multiplayer_peer = multiplayer_peer
		
		add_level()
		
		multiplayer_peer.peer_disconnected.connect(func(id): destroy_player(id))
		$Control.visible = false
		add_player(picked_fighter, 1)

func add_level():
	var level = preload("res://scenes/maps/map2.tscn").instantiate()
	$Networked.add_child(level)
	
func add_player(fighter, id=1):
	print("spawining player id " + str(id) + " (" + fighter + ")")
	var fighter_scene: PackedScene = f_burial
	
	match fighter:
		"burial":
			fighter_scene = f_burial
		"maestro":
			fighter_scene = f_maestro
	
	var character = fighter_scene.instantiate()
	character.name = str(id)
	var tp_position = MpGlobals.spawn_points.pick_random()
	tp_position += Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
	$Networked.add_child(character)
	
	MpGlobals.player_nodes[id] = character.get_path()
	await get_tree().create_timer(0.1).timeout
	
	character.global_position = tp_position
	character.rpc("teleport", tp_position)

func destroy_player(id: int):
	print("destroying player id " + str(id))
	var character = get_node(NodePath("Networked/"+ str(id)))
	character.queue_free()

@rpc("any_peer", "call_remote", "reliable")
func send_client_info(fighter):
	print(fighter)
	var id = get_tree().get_multiplayer().get_remote_sender_id()
	if not id in MpGlobals.player_nodes.keys():
		add_player(fighter, id)

func _on_option_button_item_selected(index):
	picked_fighter = $Control/PanelContainer/VBoxContainer/OptionButton.get_item_text(index)
