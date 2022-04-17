extends Node2D

var current_team

const UNIT = preload("res://Unit.tscn")

func _ready():
  pass

func execute_command(command_func: FuncRef, args):
    #$CommandSequencer.execute_command(command_func, args)
    command_func.call_func(args)

func execute_commands(commands: Array):
  for command in commands:
    yield(execute_command(command.func_ref, command.args), "completed")

func command_place_unit(args):
    var coordinate = args.coordinate
    var unit = UNIT.instance().init(coordinate.q, coordinate.r)
    unit.team = current_team
    unit.add_to_group("in_team")
    $Map.place_unit(unit)
    $Map.unit_map[coordinate.get_key()] = unit


func _on_Map_try_to_place_unit(coordinate):
  execute_command(funcref(self, "command_place_unit"), { "coordinate": coordinate })
