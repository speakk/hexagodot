extends Node2D

var current_team_index

const UNIT = preload("res://Unit.tscn")
const TEAM = preload("res://Team.tscn")

signal team_added(team)
signal turn_started(teams, team)

func add_team(name, controller, color):
  var team = TEAM.instance().init(name, controller, color, $Map)
  $Teams.add_child(team)
  team.connect("team_turn_finished", self, "end_turn")
  team.connect("try_to_place_unit", self, "_on_Map_try_to_place_unit")
  emit_signal("team_added", team)

func start_turn(team):
  print("Starting turn! %s" % team.team_name)
  team.start_turn()
  emit_signal("turn_started", $Teams, team)

func prep_teams():
  add_team("Player 1", Team.ControllerType.PLAYER, Color(0, 1, 0))
  add_team("AI 1", Team.ControllerType.AI, Color(0, 0, 1))
  
  current_team_index = 0
  var current_team = $Teams.get_child(current_team_index)
  start_turn(current_team)
  
func prep_ui():
  self.connect("team_added", $InGameUI, "on_team_added")
  self.connect("turn_started", $InGameUI, "on_turn_started")

func _ready():
  prep_ui()
  prep_teams()
  
func _process(delta):
  if Input.is_action_just_pressed("player_end_turn"):
    _on_InGameUI_player_end_turn_pressed()

func execute_command(command_func: FuncRef, args):
    #$CommandSequencer.execute_command(command_func, args)
    yield(command_func.call_func(args), "completed")

func execute_commands(commands: Array):
  for command in commands:
    yield(execute_command(command.func_ref, command.args), "completed")

func command_place_unit(args):
    var hex = args.hex
    var unit = UNIT.instance().init(hex.q, hex.r)
    unit.set_team($Teams.get_child(current_team_index))
    unit.add_to_group("in_team")
    $Map.place_unit(unit, hex)
    yield(get_tree(), "idle_frame")
    
func command_move_unit(args):
  yield($Map.animate_unit_move(args), "completed")
  $Map.place_unit(args.unit, args.hex)
  yield(get_tree(), "idle_frame")
  
func command_attack(args):
  print("Attack!")
  yield($Map.animate_unit_attack(args), "completed")
  
  yield(get_tree(), "idle_frame")
  

func _on_Map_try_to_place_unit(hex):
  execute_command(funcref(self, "command_place_unit"), { "hex": hex })

func _on_Map_try_to_move_unit(unit, hex, path):
  execute_command(funcref(self, "command_move_unit"), { "hex": hex, "unit": unit, "path": path })

func _on_try_to_move_and_attack(by, against, path):
  # Target hex is one before last (last is enemy location
  # TODO: Make unit stop where their range is maybe
  path.resize(path.size()-1)
  var target_hex = $Map.hexes[path[path.size()-1]]
  execute_commands([
    {
      "func_ref": funcref(self, "command_move_unit"),
      "args": { "hex": target_hex, "unit": by, "path": path }
     },
    {
      "func_ref": funcref(self, "command_attack"),
      "args": { "by": by, "against": against }
     }
   ])

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
