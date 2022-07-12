extends Node

enum WeaponType {
  Club, Pebble
}

var weapons = {
  WeaponType.Club: {
    "scene": preload("res://Items/Weapons/Club.tscn"),
    "item_name": "A club",
    "attack_range": 1,
    "damage": 2,
    "action_point_cost": 1,
    "spawn_chance": 0.3,
    "damage_roll": "1d6"
  },
  WeaponType.Pebble: {
    "sprite": preload("res://assets/sprites/items/weapons/rock.png"),
    "item_name": "A pebble",
    "attack_range": 2,
    "damage": 2,
    "action_point_cost": 1,
    "spawn_chance": 0.3,
    "damage_roll": "1d3"
  }
}

func load_db_values(weapon, type):
  var data = weapons.get(type)
  weapon.attack_range = data.attack_range
  weapon.damage = data.damage
  weapon.action_point_cost = data.action_point_cost
  weapon.item_name = data.item_name
  weapon.category = ItemDB.ItemCategory.Weapon
  weapon.damage_roll = data.damage_roll

func create_weapon(type) -> Weapon:
  var scene = weapons.get(type).get("scene")
  var weapon
  if scene:
    weapon = scene.instance(type)
  else:
    weapon = preload("res://Items/Weapons/Weapon.tscn").instance()
    weapon.get_node("Sprite").texture = weapons.get(type).get("sprite")
  
    
  load_db_values(weapon, type)
  return weapon
