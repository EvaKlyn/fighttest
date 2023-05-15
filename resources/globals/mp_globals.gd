extends Node

var my_alias: String
var spawn_points: Array = []

var player_nodes: Dictionary = {}

func _process(delta):
	if multiplayer.is_server():
		if is_multiplayer_authority():
			rpc("_sync_nodes", player_nodes)

@rpc("unreliable", "call_remote")
func _sync_nodes(nodes: Dictionary):
	player_nodes = nodes

@rpc
func send_spawns():
	return spawn_points

@rpc("any_peer", "reliable", "call_local")
func respawn():
	if is_multiplayer_authority():
		var id = get_tree().get_multiplayer().get_remote_sender_id()
		var path = player_nodes[id]
		var player: Player = get_node(path)
		
		print("respawning player id " + str(id))
		
		var tp_position = MpGlobals.spawn_points.pick_random()
		tp_position += Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
		
		player.rpc("teleport", tp_position)
