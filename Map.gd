extends YSort

class_name Map

#signal try_to_place_unit(coordinate)
#signal try_to_move_unit(unit, hex)
#signal try_to_move_and_attack(by, against)
signal hex_clicked(hex)
signal hex_hovered(hex)

const HEX = preload("Hex.tscn")
const UNIT = preload("Unit.tscn")

export(MapTools.MapShape) var map_shape
export(int) var map_radius = 7

# coordinate key -> unit
#var unit_map: Dictionary = {}

var hexes: Dictionary = {}

var astar = AStar2D.new()

var hilighted_path


func _ready():
  var coordinates = MapTools.create_grid(map_radius, map_shape)
  for coordinate in coordinates:
    var hex = HEX.instance().init(coordinate.q, coordinate.r)
    hex.connect("hex_clicked", self, "_on_hex_clicked")
    hex.connect("hex_hovered", self, "_on_hex_hovered")
    add_child(hex)
    hexes[coordinate.to_int()] = hex
    astar.add_point(coordinate.to_int(), MapTools.pointy_hex_to_pixel(coordinate))
  
  for coordinate in coordinates:
    var neighbor_directions = MapTools.get_neighbor_directions()
    for neighbor_direction in neighbor_directions:
      var neighbor_coordinate = MapTools.coordinate_add(coordinate, neighbor_direction)
      if astar.has_point(neighbor_coordinate.to_int()):
        astar.connect_points(coordinate.to_int(), neighbor_coordinate.to_int(), false)

func _process(dt):
  for key in hexes:
    hexes[key].path_hilight = false
    
  if hilighted_path:
    for id in hilighted_path:
      var coordinate = Coordinate.new().from_int(id)
      var hex = hexes[id]
      hex.path_hilight = true
      

func _on_hex_clicked(hex: Hex):
  emit_signal("hex_clicked", hex, hilighted_path)
  
func _on_hex_hovered(hex: Hex):
  emit_signal("hex_hovered", hex)

func hilight_path(from, to):
  hilighted_path = astar.get_id_path(from.to_int(), to.to_int())

func get_astar_path(from: Coordinate, to: Coordinate):
  return astar.get_id_path(from.to_int(), to.to_int())

  
func animate_unit_move(args):
  print("command_move_unit")
  var hex = args.hex
  var unit = args.unit
  var unit_coord = Coordinate.new(unit.q, unit.r)
  
  var existing_path = args.path
  var path
  
  if existing_path:
    path = existing_path
  else:
    path = $Map.astar.get_id_path(unit_coord.to_int(), hex.to_coordinate().to_int())
    #path.invert()
  
  var tween = $PathTween
  
  var index = 1 # Skip first one as it's the original position
  #unit.set_as_toplevel(true)
  while index < path.size():
    var coordinate = Coordinate.new().from_int(path[index])
    var original = MapTools.pointy_hex_to_pixel(unit_coord)
    var from = unit.position
    var to = MapTools.pointy_hex_to_pixel(coordinate)
    tween.interpolate_property(unit,
      "position",
      from,
      to - original,
      0.05
    )
    tween.start()
    print("Started, waiting...")
    yield(tween, "tween_completed")
    print("Tween completed")
    
    index = index + 1
  
  # Safeguard in case no distance was traveled
  yield(get_tree(), "idle_frame")

func animate_unit_attack(args):
  var by = args.by
  var against = args.against
  
  var original_position = Vector2(by.global_position)
  
  var tween = $PathTween
  tween.interpolate_property(by,
      "global_position",
      by.global_position,
      against.global_position,
      0.1
    )
  tween.start()
  yield(tween, "tween_completed")
  tween.interpolate_property(by,
      "global_position",
      by.global_position,
      original_position,
      0.2,
      Tween.EASE_OUT
    )
  tween.start()
  yield(tween, "tween_completed")
