extends Node2D

class_name EquipmentHandler

signal item_equipped(slot_id, item)

var unit

func _init(_unit):
  unit = _unit
  Events.connect("item_dragged_into_slot", self, "_on_item_dragged_into_slot")
  return self

class Slot:
  var name: String
  var item: Item
  var category
  
  func _init(_name, _category):
    name = _name
    category = _category
  
  func equip(_item):
    assert(_item.category == category)
    item = _item

var slots = {
  "hand1": Slot.new("Hand 1", ItemDB.ItemCategory.Weapon),
  "hand2": Slot.new("Hand 2", ItemDB.ItemCategory.Weapon),
  "armor": Slot.new("Armor", ItemDB.ItemCategory.Armor),
  "ring": Slot.new("Ring", ItemDB.ItemCategory.Ring)
 }

func equip(slot_id, item: Item):
  slots.get(slot_id).equip(item)
  emit_signal("item_equipped", slot_id, item)
  print("EQUIPPPPPPED", item)

func _on_item_dragged_into_slot(item, slot_id, _unit):
  if _unit == unit:
    equip(slot_id, item)
