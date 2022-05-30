extends Node

class_name Inventory

signal item_added(item)
signal item_removed(item)
signal items_changed(items)

export(Array) var items = []

func add_item(item):
  items.push_back(item)
  emit_signal("item_added", item)
  emit_signal("items_changed", items)

func remove_item(item):
  items.erase(item)
  emit_signal("item_removed", item)
  emit_signal("items_changed", items)
