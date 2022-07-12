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
  var slot_id
  var category
  
  func _init(_name, _category, _slot_id):
    name = _name
    category = _category
    slot_id = _slot_id
  
  func equip(_item):
    assert(_item.category == category)
    item = _item

var slots = {
  ItemDB.SlotId.Hand1: Slot.new("Hand 1", ItemDB.ItemCategory.Weapon, ItemDB.SlotId.Hand1),
  ItemDB.SlotId.Hand2: Slot.new("Hand 2", ItemDB.ItemCategory.Weapon, ItemDB.SlotId.Hand2),
  ItemDB.SlotId.Armor: Slot.new("Armor", ItemDB.ItemCategory.Armor, ItemDB.SlotId.Armor),
  ItemDB.SlotId.Ring: Slot.new("Ring", ItemDB.ItemCategory.Ring, ItemDB.SlotId.Ring)
 }

func equip(slot_id, item: Item):
  slots.get(slot_id).equip(item)
  Events.emit_signal("item_equipped", item, slot_id, unit)
  print("EQUIPPPPPPED", item)

func get_slot_item(slot_id):
  return slots.get(slot_id).item

func _on_item_dragged_into_slot(item, slot_id, _unit):
  if _unit == unit:
    equip(slot_id, item)
