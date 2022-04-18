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
    var hex = args.hex
    var unit = UNIT.instance().init(hex.q, hex.r)
    unit.team = current_team
    unit.add_to_group("in_team")
    $Map.place_unit(unit, hex)
    
func command_move_unit(args):
  yield($Map.animate_unit_move(args), "completed")
  $Map.place_unit(args.unit, args.hex)

func _on_Map_try_to_place_unit(hex):
  execute_command(funcref(self, "command_place_unit"), { "hex": hex })


func _on_Map_try_to_move_unit(unit, hex, path):
  execute_command(funcref(self, "command_move_unit"), { "hex": hex, "unit": unit, "path": path })
