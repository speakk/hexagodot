extends Node

enum UnitType {
  HERO, SKELLY, EGG
}

var units = {
  UnitType.HERO: {
    "name": "Hero (it's you!)",
    "health": 6,
    "damage": 1,
    "movement_points": 5,
    "attack_points": 1,
    "attack_range": 2,
    "scene": preload("res://Units/Hero.tscn")
   },
  UnitType.SKELLY: {
    "name": "Skelly",
    "health": 2,
    "damage": 1,
    "movement_points": 4,
    "attack_points": 1,
    "attack_range": 1,
    "sprite": preload("res://assets/sprites/skelly.png")
   },
    UnitType.EGG: {
    "name": "Egg (will spawn soon!)",
    "health": 1,
    "damage": 0,
    "movement_points": 0,
    "attack_points": 0,
    "attack_range": 0,
    "scene": preload("res://Units/Egg.tscn")
   }
}

func load_db_values(unit, type):
  var data = units.get(type)
  unit.unit_name = data.name
  unit.unit_type = type
  unit.health = data.get("health")
  unit.max_health = unit.health
  unit.movement_points = data.get("movement_points")
  unit.attack_points = data.get("attack_points")
  unit.max_movement_points = unit.movement_points
  unit.max_attack_points = unit.attack_points
  unit.attack_range = data.get("attack_range")
  
  if not data.get("scene"):
    unit.get_node("Sprite").texture = data.get("sprite")

func create_unit(type):
  var scene = units.get(type).get("scene")
  var unit
  if scene:
    unit = scene.instance(type)
  else:
    unit = preload("res://Units/Unit.tscn").instance(type)

  load_db_values(unit, type)
  return unit
