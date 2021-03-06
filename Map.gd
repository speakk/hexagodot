extends YSort

class_name Map

signal hex_clicked(hex)
signal hex_hovered(hex)

const HEX = preload("Terrain/Hex.tscn")
const UNIT = preload("Units/Unit.tscn")
const UNIT_SPAWN_FX = preload("Effects/UnitSpawn.tscn")

export(MapTools.MapShape) var map_shape
export(int) var map_radius = 7

# Coordinate ID -> hex/item/unit
var hexes: Dictionary = {}
var items: Dictionary = {}
var units: Dictionary = {}

var astar = AStar2D.new()

var hilighted_path

func _ready():
  Events.connect("item_spawned", self, "_on_item_spawned")
  var coordinates = MapTools.create_grid(map_radius, map_shape)
  for coordinate in coordinates:
    var hex = TerrainDB.create_terrain(coordinate.terrain_type, coordinate.q, coordinate.r)
    hex.raised = coordinate.raised
    #var hex = HEX.instance().init(coordinate.q, coordinate.r)
    hex.connect("hex_clicked", self, "_on_hex_clicked")
    hex.connect("hex_hovered", self, "_on_hex_hovered")
    hex.connect("hex_hover_exited", self, "_on_hex_hovered_exited")
    add_child(hex)
    hexes[coordinate.to_int()] = hex
    if hex.passable:
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
  
  var points = astar.get_points()
  for point in points:
    var hex = hexes[point]
    if not astar.is_point_disabled(point):
      hex.set_point_available_indicator(true)
    else:
      hex.set_point_available_indicator(false)

func _on_solid_created(point):
  astar.set_point_disabled(point.to_int(), true)

func _on_solid_removed(point):
  astar.set_point_disabled(point.to_int(), false)

func _on_solid_moved(from, to):
  astar.set_point_disabled(from.to_int(), false)
  astar.set_point_disabled(to.to_int(), true)

func _on_hex_clicked(hex: Hex):
  emit_signal("hex_clicked", hex)
  
func _on_hex_hovered_exited(hex: Hex):
  pass
  
func _on_hex_hovered(hex: Hex):
  emit_signal("hex_hovered", hex)

func set_hilighted_path(_path):
  hilighted_path = _path

func get_astar_path(from: Coordinate, to: Coordinate, max_length, trim_end = 0):
  print("get_astar_path, max_length: %s  trim_end: %s" % [max_length, trim_end])
  if trim_end > 0:
    trim_end = trim_end - 1
  
  if max_length == 0:
    return null
    
  var path = astar.get_id_path(from.to_int(), to.to_int())
  
  path.resize(min(path.size()-trim_end, max_length+1))

  if path.size() > 0:
    return path
  
func animate_unit_move(args):
  print("animate_unit_move")
  var unit = args.unit
  var unit_coord = Coordinate.new(unit.q, unit.r)
  
  var path = args.path
  
  var tween = $PathTween
  
  var index = 1 # Skip first one as it's the original position
  #unit.set_as_toplevel(true)
  while index < path.size() + 1 - unit.attack_range:
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
    yield(tween, "tween_completed")
    index = index + 1
  
  # Safeguard in case no distance was traveled
  yield(get_tree(), "idle_frame")

func _animate_ranged_attack(by: Unit, against: Unit):
  yield(get_tree(), "idle_frame")
  yield(by.perform_ranged_attack_animation(against), "completed")

func _animate_meelee_attack(by: Unit, against: Unit):
  yield(get_tree(), "idle_frame")
  
  var original_position = Vector2(by.global_position)
  print("ORIG %s, %s" % [original_position.x, original_position.y])
  
  var tween = $PathTween
  tween.remove_all()
  var result = tween.interpolate_property(by,
      "global_position",
      by.global_position,
      against.global_position,
      0.1
    )
  result = tween.start()
  yield(tween, "tween_completed")
  tween.remove_all()
  print("Okay animating back %s to %s" % [by.global_position, original_position])
  result = tween.interpolate_property(by,
      "global_position",
      by.global_position,
      original_position,
      0.2,
      Tween.EASE_OUT
    )
  result = tween.start()
  yield(tween, "tween_completed")
  
func animate_unit_attack(args):
  yield(get_tree(), "idle_frame")
  var by = args.by
  var against = args.against
  
  if by.attack_range > 1:
    yield(_animate_ranged_attack(by, against), "completed")
  else:
    yield(_animate_meelee_attack(by, against), "completed")

func get_random_free_hex():
  var hexes_values = hexes.values()
  hexes_values.shuffle()
  for hex in hexes_values:
    if hex.get_node("Units").get_child_count() == 0 \
    and hex.get_node("Items").get_child_count() == 0 \
    and hex.passable:
        return hex

func _place_solid(solid, hex, from):
  solid.global_position = hex.global_position
  solid.z_index = 1
  if not from or (from.q == hex.q and from.r == hex.r):
    #call_deferred("emit_signal", "solid_created", hex.to_coordinate())
    call_deferred("_on_solid_created", hex.to_coordinate())
  else:
    #call_deferred("emit_signal", "solid_moved", from, hex.to_coordinate())
    call_deferred("_on_solid_moved",from, hex.to_coordinate())
    
func place_item(item, hex):
  if item.get_parent():
    item/get_parent().remove_child(item)
  hex.get_node("Items").add_child(item)
  _place_solid(item, hex, null)

func spawn_unit(unit, hex):
  hex.get_node("Units").add_child(unit)
  unit.place(hex.q, hex.r, 0)
  var fx = UNIT_SPAWN_FX.instance()
  unit.add_child(fx)
  _place_solid(unit, hex, null)

func place_unit(unit, hex, movement_points = 0):
  if unit.get_parent():
    unit.get_parent().remove_child(unit)
  hex.get_node("Units").add_child(unit)
  var original_from = Coordinate.new(unit.q, unit.r)
  unit.place(hex.q, hex.r, movement_points)
  Events.emit_signal("unit_entered_hex", unit, hex)
  
  _place_solid(unit, hex, original_from)

func place_torch(q, r):
  var TORCH = preload("res://Items/Torch.tscn")
  var torch = TORCH.instance()
  var hex = hexes[Coordinate.new(q, r).to_int()]
  place_item(torch, hex)

func place_torches():
  place_torch(-7, 0)
  place_torch(6, 0)
  
  place_torch(0, -7)
  place_torch(0, 6)
  
  place_torch(6, -7)
  place_torch(-7, 6)

#func place_terrain_blocks():
#  var BASIC_BLOCK = preload("res://Terrain/BasicBlock.tscn")
#
#  for i in range(12):
#    var basic_block = BASIC_BLOCK.instance()
#    place_item(basic_block, get_random_free_hex())

func _on_item_spawned(item, coordinate):
  var hex = hexes[coordinate.to_int()]
  hex.get_node("Items").add_child(item)
  if item.solid:
    _place_solid(item, hex, null)
