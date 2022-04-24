extends Node

class_name Team

signal team_turn_finished(team)
signal try_to_place_unit(hex)
signal try_to_move_and_attack(by, against)

enum ControllerType {
  PLAYER, AI
}

# Unique, identifies team
var team_name = ""
var controller: int
var color: Color
var map
var ai

func init(_name: String, _controller: int, _color: Color, _map):
  team_name = _name
  controller = _controller
  color = _color
  map = _map
  ai = AI.new(self, map)
  add_child(ai)
  return self

func get_team_units():
  var team_units = []
  var units = get_tree().get_nodes_in_group("unit_in_team")
  for unit in units:
    if unit.is_in_group(team_name):
      team_units.push_back(unit)
  
  return team_units

func get_enemy_units():
  var enemy_units = []
  var units = get_tree().get_nodes_in_group("unit_in_team")
  for unit in units:
    if not unit.is_in_group(team_name):
      enemy_units.push_back(unit)
      
  return enemy_units
        
func reset_unit_points():
  var units = get_team_units()
  for unit in units:
    unit.reset_points()

func start_turn():
  reset_unit_points()
  if controller == ControllerType.PLAYER:
    print("PLAYER TURN HAS STARTED")
    pass
  else:
    print("AI TURN HAS STARTED")
    ai.perform_turn()

enum Commands {
  END_TURN,
  ATTACK,
  MOVE_UNIT
}

