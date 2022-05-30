extends PanelContainer

func _on_items_changed(items):
  $VBoxContainer/InventoryList._on_items_changed(items)
