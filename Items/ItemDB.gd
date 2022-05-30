extends Node

enum ItemType {
  HealthPotion
}

var items = {
  ItemType.HealthPotion: {
    "scene": preload("res://Items/HealthPotion.tscn"),
    "solid": false,
    "spawn_chance": 0.1,
    "item_name": "Health Potion"
  }
}

func load_db_values(item, type):
  var data = items.get(type)
  item.solid = data.solid
  item.item_name = data.item_name

func create_item(type) -> Item:
  var scene = items.get(type).get("scene")
  var item
  if scene:
    item = scene.instance(type)
  else:
    item = preload("res://Items/Item.tscn").instance(type)

  load_db_values(item, type)
  return item
