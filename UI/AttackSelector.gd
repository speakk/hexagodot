extends PanelContainer

export(ItemDB.SlotId) var slot_id = ItemDB.SlotId.Armor
var selected_unit

func _ready():
  Events.connect("item_equipped", self, "_on_item_equipped")
  Events.connect("unit_selected", self, "_on_unit_selected")
  Events.connect("attack_selected", self, "_on_attack_selected")
  update_ui()

func _on_unit_selected(unit):
  selected_unit = unit
  update_ui()

func _on_item_equipped(_item, _slot_id, _unit):
  if _slot_id == slot_id and _unit == selected_unit:
    update_ui()
    
func show_as_disabled(label):
  $HBoxContainer.visible = false
  $DisabledLabel.text = label
  $DisabledLabel.visible = true

func show_as_enabled():
  $DisabledLabel.visible = false
  $HBoxContainer.visible = true

func update_ui():
  if selected_unit:
    var item = selected_unit.get_equipped_item(slot_id)
    if item:
      show_as_enabled()
      $HBoxContainer/InventoryListRow.init(item)
      $HBoxContainer/ActionPointCostLabel.text = "(%sap)" % item.action_point_cost
    else:
      show_as_disabled("No item equipped")
  else:
    show_as_disabled("No unit selected")

func _on_attack_selected(_unit, _slot_id, _item):
  if _unit == selected_unit and _slot_id == slot_id:
    handle_selected(true)
  else:
    handle_selected(false)

func handle_selected(value):
  $SelectedBorder.visible = value
  
func _on_selector_input_event(viewport, event, shape_idx):
  if event == InputEventMouseButton:
    if event.button_index == 0:
      handle_select_click()

func handle_select_click():
  Events.emit_signal("attack_selected", selected_unit, slot_id, selected_unit.get_equipped_item(slot_id))
