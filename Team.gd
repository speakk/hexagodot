extends Node

class_name Team

signal team_turn_finished(team)
signal try_to_place_unit(hex)

enum ControllerType {
  PLAYER, AI
}

# Unique, identifies team
var team_name = ""
var controller: int
var color: Color
var map

func init(_name: String, _controller: int, _color: Color, _map):
  team_name = _name
  controller = _controller
  color = _color
  map = _map
  return self

func start_turn():
  if controller == ControllerType.PLAYER:
    print("PLAYER TURN HAS STARTED")
    pass
  else:
    print("AI TURN HAS STARTED")
    perform_ai_turn()
    
func perform_ai_turn():
  print("Perform ai turn")
  var hexes = map.hexes.values()
  var rand_hex = hexes[randi() % hexes.size()]
  emit_signal("try_to_place_unit", rand_hex)
  yield(get_tree().create_timer(1.0), "timeout")
  emit_signal("team_turn_finished")

enum Commands {
  END_TURN,
  ATTACK,
  MOVE_UNIT
}

