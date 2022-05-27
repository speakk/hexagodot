extends Node

var all_items = []
var weights = PoolRealArray()

var creation_funcs = {
  "item": funcref(ItemDB, "create_item"),
  "weapon": funcref(WeaponDB, "create_weapon"),
 }

func _init():
  Events.connect("unit_died", self, "spawn_item")
  for item in ItemDB.items.keys():
    all_items.push_back({
      "item": item,
      "type": "item"
     })
    weights.push_back(ItemDB.items.get(item).spawn_chance)
  
  for weapon in WeaponDB.weapons.keys():
    all_items.push_back({
      "item": weapon,
      "type": "weapon"
     })
    #weights.push_back(weapon.spawn_chance)
    weights.push_back(WeaponDB.weapons.get(weapon).spawn_chance)
  
  #all_items.sort_custom(self, "item_probability_sort")

func spawn_item(unit: Unit):
  if randf() < 1.0:
    var random_index = weighted_random(weights)
    var item_entry = all_items[random_index]
    var item = creation_funcs.get(item_entry.type).call_func(item_entry.item)
    
    #var item = ItemDB.create_item(ItemDB.ItemType.HealthPotion)
    item.position = unit.position
    var coordinate = unit.get_coordinate()
    Events.emit_signal("item_spawned", item, coordinate)

static func weighted_random(weights: PoolRealArray) -> int:
  var weights_sum := 0.0
  for weight in weights:
    weights_sum += weight
  
  var remaining_distance := randf() * weights_sum
  for i in weights.size():
    remaining_distance -= weights[i]
    if remaining_distance < 0:
      return i
  
  return 0
