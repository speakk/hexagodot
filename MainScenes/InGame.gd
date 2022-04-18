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
  print("command_move_unit")
  var hex = args.hex
  var unit = args.unit
  var unit_coord = Coordinate.new(unit.q, unit.r)
  
  var existing_path = args.path
  var path
  
  if existing_path:
    path = existing_path
  else:
    path = $Map.astar.get_id_path(hex.to_coordinate().to_int(), unit_coord.to_int())
  
  var tween = $PathTween
  
  path.invert()
  var index = 0
  #unit.set_as_toplevel(true)
  while index < path.size():
    print("Index, path %s %s" % [index, path])
    var coordinate = Coordinate.new().from_int(path[index])
    var original = MapTools.pointy_hex_to_pixel(unit_coord)
    var from = unit.position
    var to = MapTools.pointy_hex_to_pixel(coordinate)
    print(unit_coord.q, hex.q)
    print("from: %s, to: %s" % [from, to])
    tween.interpolate_property(unit,
      "position",
      from,
      to - original,
      1
    )
    tween.start()
    print("Started, waiting...")
    yield(tween, "tween_completed")
    print("Completed")
    index = index + 1
    
  $Map.place_unit(unit, hex)

func _on_Map_try_to_place_unit(hex):
  execute_command(funcref(self, "command_place_unit"), { "hex": hex })


func _on_Map_try_to_move_unit(unit, hex, path):
  execute_command(funcref(self, "command_move_unit"), { "hex": hex, "unit": unit, "path": path })
