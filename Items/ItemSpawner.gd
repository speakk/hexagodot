extends Node

func _init():
  Events.connect("unit_died", self, "spawn_item")

func spawn_item(unit: Unit):
  if randf() < 0.3:
    var item = ItemDB.create_item(ItemDB.ItemType.HealthPotion)
    item.position = unit.position
    var coordinate = unit.get_coordinate()
    Events.emit_signal("item_spawned", item, coordinate)
