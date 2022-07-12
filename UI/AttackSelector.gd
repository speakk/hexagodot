extends PanelContainer

export(ItemDB.SlotId) var slot_id = ItemDB.SlotId.Armor
var selected_unit

func _ready():
  Events.connect("item_equipped", self, "_on_item_equipped")
  Events.connect("unit_selected", self, "_on_unit_selected")

func _on_unit_selected(unit):
  selected_unit = unit
  update_ui()

func _on_item_equipped(_item, _slot_id, _unit):
  if _slot_id == slot_id and _unit == selected_unit:
    update_ui()

func update_ui():
  if selected_unit:
    var item = selected_unit.get_equipped_item(slot_id)
    if item:
      $HBoxContainer/InventoryListRow.init(item)
      $HBoxContainer/ActionPointCostLabel.text = "(%sap)" % item.action_point_cost
