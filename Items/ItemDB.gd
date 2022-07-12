extends Node

enum ItemType {
  HealthPotion
}

enum ItemCategory {
  Potion, Weapon, Armor, Ring
 }

enum SlotId {
  Hand1, Hand2, Armor, Ring
 }

var items = {
  ItemType.HealthPotion: {
    "scene": load("res://Items/HealthPotion.tscn"),
    "solid": false,
    "spawn_chance": 0.1,
    "item_name": "Health Potion",
    "category": ItemCategory.Potion,
    "action_point_cost": 2
  }
}

func load_db_values(item, type):
  var data = items.get(type)
  item.solid = data.solid
  item.item_name = data.item_name
  item.category = data.category
  item.action_point_cost = data.action_point_cost or 0

func create_item(type) -> Item:
  var scene = items.get(type).get("scene")
  var item
  if scene:
    item = scene.instance(type)
  else:
    item = load("res://Items/Item.tscn").instance(type)

  load_db_values(item, type)
  return item
