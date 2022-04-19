extends Node

enum UnitType {
  HERO, SKELLY
}

var units = {
  UnitType.HERO: {
    "health": 3,
    "damage": 1,
    "sprite": preload("res://assets/sprites/stabby.png")
   },
  UnitType.SKELLY: {
    "health": 2,
    "damage": 1,
    "sprite": preload("res://assets/sprites/skelly.png")
   },
}

func load_db_values(unit, type):
  var data = units.get(type)
  unit.health = data.get("health")
  unit.max_health = unit.health
  unit.get_node("Sprite").texture = data.get("sprite")
