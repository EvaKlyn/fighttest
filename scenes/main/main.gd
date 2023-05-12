extends Node

var host: String
var port: int

var multiplayer_peer = ENetMultiplayerPeer.new()
var spawn_point: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if ("--server" in OS.get_cmdline_args() || OS.has_feature("dedicated_server")):
		print("starting server...")
		port = 6665
		multiplayer_peer.create_server(port)
		multiplayer.multiplayer_peer = multiplayer_peer
		
		print("spawining level...")
		add_level()
		
		multiplayer_peer.peer_connected.connect(func(id): add_player(id))
		multiplayer_peer.peer_disconnected.connect(func(id): destroy_player(id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
		
		multiplayer_peer.peer_connected.connect(func(id): add_player(id))
		multiplayer_peer.peer_disconnected.connect(func(id): destroy_player(id))
		$Control.visible = false
		add_player()

func add_level():
	var level = preload("res://scenes/map.tscn").instantiate()
	$Networked.add_child(level)
	
func add_player(id=1):
	print("spawining player id " + str(id))
	var character = preload("res://scenes/player/classes/burial.tscn").instantiate()
	character.name = str(id)
	var tp_position = MpGlobals.spawn_points.pick_random()
	tp_position += Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
	$Networked.add_child(character)
	
	MpGlobals.player_nodes[id] = character.get_path()
	print(MpGlobals.player_nodes)
	await get_tree().create_timer(0.1).timeout
	
	character.global_position = tp_position
	character.rpc("teleport", tp_position)

func destroy_player(id: int):
	print("destroying player id " + str(id))
	var character = get_node(NodePath("Networked/"+ str(id)))
	character.queue_free()


func _on_low_graphics_check_toggled(button_pressed):
	PlayerSettings.potato_mode = button_pressed
