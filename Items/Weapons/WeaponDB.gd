extends Node

enum WeaponType {
  Club
}

var weapons = {
  WeaponType.Club: {
    "scene": preload("res://Items/Weapons/Club.tscn"),
    "item_name": "A club",
    "attack_range": 1,
    "damage": 2,
    "action_point_cost": 1,
    "spawn_chance": 0.3
  }
}

func load_db_values(weapon, type):
  var data = weapons.get(type)
  weapon.attack_range = data.attack_range
  weapon.damage = data.damage
  weapon.action_point_cost = data.action_point_cost
  weapon.item_name = data.item_name

func create_weapon(type) -> Weapon:
  var scene = weapons.get(type).get("scene")
  var weapon = scene.instance(type)

  load_db_values(weapon, type)
  return weapon
