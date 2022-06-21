extends PanelContainer

export var slot_name: String = "" setget set_slot_name
export var slot_id: String = ""
export(ItemDB.ItemCategory) var item_category = ItemDB.ItemCategory.Armor

var unit

func _init():
  Events.connect("unit_selected", self, "_on_unit_selected")

func set_slot_name(value):
  $HBoxContainer/InventoryListRow/Label.text = value
  slot_name = value

func can_drop_data(_position, data):
  assert(unit)
  print("CATEGORY", data.get("item").category)
  print("own category:", item_category)
  return data is Dictionary and data.has("item") and data.get("item").category == item_category

func drop_data(_position, data):
  assert(unit)
  $HBoxContainer/InventoryListRow.init(data.get("item"))
  Events.emit_signal("item_dragged_into_slot", data.get("item"), slot_id, unit)

func _on_unit_selected(_unit):
  unit = _unit
