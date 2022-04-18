extends YSort

class_name Map

signal try_to_place_unit(coordinate)
signal try_to_move_unit(unit, hex)

const HEX = preload("Hex.tscn")
const UNIT = preload("Unit.tscn")

export(MapTools.MapShape) var map_shape
export(int) var map_radius = 7

# coordinate key -> unit
#var unit_map: Dictionary = {}

var hexes: Dictionary = {}

var astar = AStar2D.new()

var hilighted_path

var selected_unit

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
  var coordinate = hex.to_coordinate()
  var hex_units = hexes[coordinate.to_int()].get_node("Units").get_children()
  print("Hex units size", hex_units.size())
  if hex_units.size() > 0:
    for key in hexes:
      var other_hex = hexes[key]
      for unit in other_hex.get_node("Units").get_children():
        unit.deselect()
    select_unit(hex_units[0])
  else:
    if selected_unit:
      emit_signal("try_to_move_unit", selected_unit, hex, hilighted_path)
    else:
      emit_signal("try_to_place_unit", hex)
    
func _on_hex_hovered(hex: Hex):
  if selected_unit:
    var from_coord = selected_unit.get_coordinate()
    hilighted_path = astar.get_id_path(hex.to_coordinate().to_int(), from_coord.to_int())

func place_unit(unit, hex):
  if unit.get_parent():
    unit.get_parent().remove_child(unit)
  hex.get_node("Units").add_child(unit)
  unit.global_position = hex.global_position
  unit.z_index = 1
  unit.place(hex.q, hex.r)
  clear_last_selected()
  
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
    path = $Map.astar.get_id_path(hex.to_coordinate().to_int(), unit_coord.to_int())
  
  var tween = $PathTween
  
  path.invert()
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
    
  #$Map.place_unit(unit, hex)

func select_unit(unit):
  unit.select()
  selected_unit = unit
  
func move_unit(unit, to):
  pass

func clear_last_selected():
  if selected_unit:
    selected_unit.deselect()
    selected_unit = null
  
  hilighted_path = null
