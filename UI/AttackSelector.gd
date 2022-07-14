extends PanelContainer

export(ItemDB.SlotId) var slot_id = ItemDB.SlotId.Armor
var selected_unit

onready var me = self

const DESELECTED_COLOR = Color(0.4, 0.3, 0.3)
const SELECTED_COLOR = Color(1, 1, 0.4)

func _ready():
  Events.connect("item_equipped", self, "_on_item_equipped")
  Events.connect("unit_selected", self, "_on_unit_selected")
  Events.connect("attack_selected", self, "_on_attack_selected")
  get_stylebox("panel").set_border_width_all(1)
  get_stylebox("panel").border_color = DESELECTED_COLOR
  update_ui()

func _on_unit_selected(unit):
  selected_unit = unit
  update_ui()

func _on_item_equipped(_item, _slot_id, _unit):
  #if _slot_id == slot_id and _unit == selected_unit:
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
  print("_on_attack_selected", slot_id, _slot_id, _unit, selected_unit)
  if _unit == selected_unit and _slot_id == slot_id:
    print("Setting handle selected true")
    handle_selected(true)
  else:
    handle_selected(false)

func handle_selected(value):
  if value:
    print("Setting panel foot")
    #me.get_stylebox("panel").set_border_width_all(2)
    get_stylebox("panel").border_color = SELECTED_COLOR
  else:
    print("Setting panel width to zeroo")
    #me.get_stylebox("panel").set_border_width_all(1)
    get_stylebox("panel").border_color = DESELECTED_COLOR
  
func handle_select_click():
  if selected_unit:
    print("Emitting attack_selected")
    Events.emit_signal("attack_selected", selected_unit, slot_id, selected_unit.get_equipped_item(slot_id))

func _on_AttackSelector_gui_input(event):
    #if event.type == InputEventMouseButton:
  if event is InputEventMouseButton:
    print("CLICKED SELECTOR", event)
    print("CLICKED SELECTOR2", event.button_index)
    if event.button_index == BUTTON_LEFT:
      handle_select_click()
