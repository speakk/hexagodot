extends Node

func find_closest(unit, others: Array):
  if others.size() == 0:
    return null
    
  var shortest_distance = 100000 # TODO: Couldn't find an equivalent of math.huge
  var closest_unit = others[0]
  for other in others:
    var distance = MapTools.get_distance(unit.get_coordinate(), other.get_coordinate())
    if distance < shortest_distance:
      closest_unit = other
      shortest_distance = distance
  
  return closest_unit

func attack_closest_enemy(by):
  yield(get_tree(), "idle_frame")  
  print("Attacking closest enemy")
  var team = by.team
  var enemy_units = team.get_enemy_units()
  var closest_unit = find_closest(by, enemy_units)
  if closest_unit:
    print("Found closest unit ", closest_unit)
    var scene = SceneManager.get_current_scene()
    var path = scene.get_shortest_path_to_occupied_tile(by.get_coordinate(), closest_unit.get_coordinate(), by)
    #scene.get_node("Map").set_hilighted_path(path)
    yield(scene.try_to_move_and_attack(by, closest_unit, path), "completed")
    print("Emitted, right?")
  
func do_unit_actions(team):
  print("do_unit_actions")
  for unit in team.get_team_units():
    print("Found unit in team units")
    yield(attack_closest_enemy(unit), "completed")

func spawn_random_egg(team):
  yield(get_tree(), "idle_frame")  
  print("Spawning eggsy")
  var scene = SceneManager.get_current_scene()
  var map = scene.get_map()
  var hexes = map.hexes.values()
  var rand_hex = hexes[randi() % hexes.size()]
  team.emit_signal("try_to_place_unit", rand_hex, team)
  yield(scene.get_tree().create_timer(0.4), "timeout")


#func perform_turn():
#  var scene = SceneManager.get_current_scene()
#  var map = scene.get_map()
#  print("Perform ai turn")
#  var hexes = map.hexes.values()
#  var rand_hex = hexes[randi() % hexes.size()]
#  team.emit_signal("try_to_place_unit", rand_hex)
#  yield(scene.get_tree().create_timer(1.0), "timeout")
#  do_unit_actions()
#  team.emit_signal("team_turn_finished")
