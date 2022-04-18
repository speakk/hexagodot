extends Node

class_name Team

signal team_turn_finished(team)

enum ControllerType {
  PLAYER, AI
}

# Unique, identifies team
var team_name = ""

var controller: int

func init(_name: String, _controller: int):
  team_name = _name
  controller = _controller
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
  yield(get_tree().create_timer(1.0), "timeout")
  emit_signal("team_turn_finished")

enum Commands {
  END_TURN,
  ATTACK,
  MOVE_UNIT
}

