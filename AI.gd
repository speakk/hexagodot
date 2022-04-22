extends Node

class_name AI

var team
var map

func _init(_team, _map):
  team = _team
  map = _map

func perform_turn():
  var scene = SceneManager.get_current_scene()
  print("Perform ai turn")
  var hexes = map.hexes.values()
  var rand_hex = hexes[randi() % hexes.size()]
  team.emit_signal("try_to_place_unit", rand_hex)
  yield(scene.get_tree().create_timer(1.0), "timeout")
  team.emit_signal("team_turn_finished")
