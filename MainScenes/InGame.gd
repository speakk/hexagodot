extends Node2D

var current_team_index

const UNIT = preload("res://Unit.tscn")
const TEAM = preload("res://Team.tscn")

signal team_added(team)
signal turn_started(teams, team)

func add_team(name, controller):
  var team = TEAM.instance().init(name, controller)
  $Teams.add_child(team)
  team.connect("team_turn_finished", self, "end_turn")
  emit_signal("team_added", team)

func start_turn(team):
  print("Starting turn! %s" % team.team_name)
  team.start_turn()
  emit_signal("turn_started", $Teams, team)

func prep_teams():
  add_team("Player 1", Team.ControllerType.PLAYER)
  add_team("AI 1", Team.ControllerType.AI)
  
  current_team_index = 0
  var current_team = $Teams.get_child(current_team_index)
  start_turn(current_team)
  
func prep_ui():
  self.connect("team_added", $InGameUI, "on_team_added")
  self.connect("turn_started", $InGameUI, "on_turn_started")

func _ready():
  prep_ui()
  prep_teams()

func execute_command(command_func: FuncRef, args):
    #$CommandSequencer.execute_command(command_func, args)
    command_func.call_func(args)

func execute_commands(commands: Array):
  for command in commands:
    yield(execute_command(command.func_ref, command.args), "completed")

func command_place_unit(args):
    var hex = args.hex
    var unit = UNIT.instance().init(hex.q, hex.r)
    unit.team = $Teams.get_child(current_team_index)
    unit.add_to_group("in_team")
    $Map.place_unit(unit, hex)
    
func command_move_unit(args):
  yield($Map.animate_unit_move(args), "completed")
  $Map.place_unit(args.unit, args.hex)

func _on_Map_try_to_place_unit(hex):
  execute_command(funcref(self, "command_place_unit"), { "hex": hex })

func _on_Map_try_to_move_unit(unit, hex, path):
  execute_command(funcref(self, "command_move_unit"), { "hex": hex, "unit": unit, "path": path })

func end_turn():
  print("Ending turn for team %s" % $Teams.get_child(current_team_index).team_name)
  current_team_index = (current_team_index + 1) % $Teams.get_child_count()
  print("Ending turn, new index %s" % current_team_index)
  var current_team = $Teams.get_child(current_team_index)
  call_deferred("start_turn", current_team)
  
func _on_InGameUI_player_end_turn_pressed():
  var current_team = $Teams.get_child(current_team_index)
  if current_team.controller == Team.ControllerType.PLAYER:
    #current_team.emit_signal("team_turn_finished", current_team)
    end_turn()
