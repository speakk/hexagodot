extends Node2D

var current_team_index
var selected_unit
var last_hilighted_path

const UNIT = preload("res://Unit.tscn")
const TEAM = preload("res://Team.tscn")

signal team_added(team)
signal turn_started(teams, team)
signal unit_moved(from, to)

func add_team(name, controller, color):
  var team = TEAM.instance().init(name, controller, color, $Map)
  $Teams.add_child(team)
  team.connect("team_turn_finished", self, "end_turn")
  team.connect("try_to_place_unit", self, "try_to_place_unit")
  emit_signal("team_added", team)

func start_turn(team):
  print("Starting turn! %s" % team.team_name)
  team.start_turn()
  emit_signal("turn_started", $Teams, team)

func prep_teams():
  add_team("Player 1", Team.ControllerType.PLAYER, Color(0, 1, 0))
  add_team("AI 1", Team.ControllerType.AI, Color(0, 0, 1))

func create_hero():
  for team in $Teams.get_children():
    if team.controller == Team.ControllerType.PLAYER:
      var hex = $Map.hexes.values()[randi() % $Map.hexes.size()]
      var hero = UNIT.instance().init(hex.q, hex.r, UnitDB.UnitType.HERO)
      hero.set_team(team)
      place_unit(hero, hex)
  
func prep_ui():
  self.connect("team_added", $InGameUI, "on_team_added")
  self.connect("turn_started", $InGameUI, "on_turn_started")

func _ready():
  randomize()
  prep_ui()
  prep_teams()
  create_hero()
  $Map.connect("hex_clicked", self, "_on_Map_hex_clicked")
  $Map.connect("hex_hovered", self, "_on_Map_hex_hovered")
  self.connect("unit_moved", $Map, "_on_unit_moved")
  
  current_team_index = 0
  var current_team = get_current_team()
  start_turn(current_team)
  
func _process(_delta):
  if Input.is_action_just_pressed("player_end_turn"):
    _on_InGameUI_player_end_turn_pressed()

func execute_command(command_func: FuncRef, args):
    #$CommandSequencer.execute_command(command_func, args)
    var result = yield(command_func.call_func(args), "completed")
    return result

func execute_commands(commands: Array):
  for command in commands:
    var success = yield(execute_command(command.func_ref, command.args), "completed")
    print("Command result %s for %s" % [success, command.func_ref.name])
    if not success:
      break
  
  return true

func command_place_unit(args):
    var hex = args.hex
    var unit = UNIT.instance().init(hex.q, hex.r, UnitDB.UnitType.SKELLY)
    unit.set_team($Teams.get_child(current_team_index))
    unit.add_to_group("in_team")
    place_unit(unit, hex)
    yield(get_tree(), "idle_frame")
    
func command_move_unit(args):
  print("in command_move unit, pathsize vs mov points: %s %s" % [args.path.size(), args.unit.movement_points])
  if args.path.size() == 0 || args.path.size() > args.unit.movement_points:
    yield(get_tree(), "idle_frame")
    print("UH, path size was over yea")
    return false
    
  yield($Map.animate_unit_move(args), "completed")
  place_unit(args.unit, $Map.hexes[args.path[args.path.size()-1]], args.path.size())
  yield(get_tree(), "idle_frame")
  return true
  
func command_attack(args):
  print("Attack!")
  yield($Map.animate_unit_attack(args), "completed")
  yield(get_tree(), "idle_frame")
  args.against.take_damage(args.by.damage_amount)
  
func select_unit(unit):
  unit.select()
  selected_unit = unit
  
func get_current_team():
  return $Teams.get_child(current_team_index)

func handle_hex_click(hex):
  print("handle_hex_click")
  if get_current_team().controller == Team.ControllerType.AI:
    return
  
  var original_target_hex = hex
  
  if last_hilighted_path:
    hex = $Map.hexes[last_hilighted_path[last_hilighted_path.size()-1]]
  
  var target_original = original_target_hex == hex
    
  print("Had last hilighted path, picking the last hex from that")
  
  var hex_units = hex.get_node("Units").get_children()
  print("Hex units size", hex_units.size())
  if hex_units.size() > 0:
    print("There was a unit on the tile!")
    var existing_unit = hex_units[0]
    
    # No unit selected, or current team is same as unit in tile
    if (not selected_unit) and get_current_team() == existing_unit.team:
      print("No unit selected, or current team is same as unit in tile")
      for key in $Map.hexes:
        var other_hex = $Map.hexes[key]
        for unit in other_hex.get_node("Units").get_children():
          unit.deselect()
        
      print("So, selecting unit on tile")
      select_unit(existing_unit)
    elif selected_unit and get_current_team() != existing_unit.team and last_hilighted_path:
      print("Already had a selected unit, and the new tile has a unit NOT on the same team, AND we have a last hilighted path")
      print("Which means, ATTACK")
      try_to_move_and_attack(selected_unit, existing_unit, last_hilighted_path)
  else:
    print("There was no unit on the newly selected tile!")
    if selected_unit and last_hilighted_path:
      print("We already have a unit selected, so try to move that one")
      try_to_move_unit(selected_unit, last_hilighted_path)
    elif not selected_unit:
      print("No unit selected, so place a new one")
      try_to_place_unit(hex)
  

func try_to_place_unit(hex):
  execute_command(funcref(self, "command_place_unit"), { "hex": hex })

func try_to_move_unit(unit, path):
  execute_command(funcref(self, "command_move_unit"), { "unit": unit, "path": path })

func try_to_move_and_attack(by, against, path):
  # Target hex is one before last (last is enemy location
  # TODO: Make unit stop where their range is maybe
  #path.resize(path.size()-1)
  #var target_hex = $Map.hexes[path[path.size()-1]]
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


func clear_last_selected():
  if selected_unit:
    selected_unit.deselect()
    selected_unit = null
  
  $Map.hilighted_path = null
  last_hilighted_path = null

func place_unit(unit, hex, movement_points = 0):
  var original_from = Coordinate.new(unit.q, unit.r)
  if unit.get_parent():
    unit.get_parent().remove_child(unit)
  hex.get_node("Units").add_child(unit)
  unit.global_position = hex.global_position
  unit.z_index = 1
  unit.place(hex.q, hex.r, movement_points)
  clear_last_selected()
  emit_signal("unit_moved", original_from, hex.to_coordinate())

func end_turn():
  print("Ending turn for team %s" % get_current_team().team_name)
  current_team_index = (current_team_index + 1) % $Teams.get_child_count()
  print("Ending turn, new index %s" % current_team_index)
  var current_team = get_current_team()
  call_deferred("start_turn", current_team)
  
func _on_InGameUI_player_end_turn_pressed():
  var current_team = get_current_team()
  if current_team.controller == Team.ControllerType.PLAYER:
    #current_team.emit_signal("team_turn_finished", current_team)
    end_turn()

func _on_Map_hex_clicked(hex):
  handle_hex_click(hex)

func _on_Map_hex_hovered(hex):
  if selected_unit:
    var coordinate = hex.to_coordinate()
    var from_coord = selected_unit.get_coordinate()
    var existing_units = hex.get_units()
    
    if existing_units.size() == 0:
      last_hilighted_path = $Map.get_astar_path(from_coord, coordinate, selected_unit.movement_points)
      $Map.set_hilighted_path(last_hilighted_path)
    else:
      var potential_paths = []
      var neighbor_directions = MapTools.get_neighbor_directions()
      for neighbor_direction in neighbor_directions:
        var neighbor_coordinate = MapTools.coordinate_add(coordinate, neighbor_direction)
        if $Map.astar.has_point(neighbor_coordinate.to_int()):
          potential_paths.push_back($Map.get_astar_path(from_coord, neighbor_coordinate, selected_unit.movement_points))
      
      var shortest_path
      for potential_path in potential_paths:
        if not shortest_path or potential_path.size() < shortest_path.size():
          shortest_path = potential_path
      
      print("Alright found the shortest path")
      last_hilighted_path = shortest_path
      $Map.set_hilighted_path(last_hilighted_path)
