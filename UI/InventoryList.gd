extends VBoxContainer

onready var INVENTORY_LIST_ROW = preload("res://UI/InventoryListRow.tscn")

func _on_items_changed(items):
  for n in get_children():
    remove_child(n)
    n.queue_free()

  for item in items:
    print("Adding item", item.item_name)
    var list_row = INVENTORY_LIST_ROW.instance().init(item)
    add_child(list_row)
    
